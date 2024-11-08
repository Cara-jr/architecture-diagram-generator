import os
import json
import boto3
import base64
import logging
import tempfile
from botocore.exceptions import ClientError
import requests

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Load configuration based on environment
try:
    ENV = os.environ.get('ENV', 'dev')
    if ENV == 'prod':
        from config.prod_config import CLAUDE_API_KEY, S3_BUCKET_NAME
    else:
        from config.dev_config import CLAUDE_API_KEY, S3_BUCKET_NAME
except ImportError as e:
    logger.error(f"Configuration import error: {e}")
    raise

# Initialize AWS S3 client
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        # Get the uploaded code from event input
        code_content_base64 = event.get('code_content')
        if not code_content_base64:
            raise ValueError("No code_content provided in input")

        code_content = base64.b64decode(code_content_base64).decode('utf-8')

        # Save code to a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.py') as temp_code_file:
            temp_code_file.write(code_content.encode('utf-8'))
            code_file_path = temp_code_file.name

        # Generate pseudocode
        pseudocode = generate_pseudocode(code_file_path)
        pseudocode_file_key = upload_to_s3(pseudocode, 'pseudocode.txt')

        # Return the S3 key for the next function
        return {'pseudocode_key': pseudocode_file_key}

    except Exception as e:
        logger.error(f"Error in translate_to_pseudocode: {e}")
        raise e

def generate_pseudocode(code_file_path):
    try:
        with open(code_file_path, 'r') as code_file:
            code_content = code_file.read()

        prompt = f"Translate the following code into pseudocode, focusing on important function calls and database interactions. Use a fixed format:\n\n{code_content}"
        headers = {
            'x-api-key': CLAUDE_API_KEY,
            'Content-Type': 'application/json'
        }
        data = {
            'prompt': prompt,
            'model': 'claude-2',
            'max_tokens_to_sample': 1500,
            'stop_sequences': ['\n\nHuman:'],
            'temperature': 0.5,
        }
        response = requests.post('https://api.anthropic.com/v1/complete', headers=headers, json=data)
        response.raise_for_status()
        result = response.json()
        pseudocode = result.get('completion', '')
        if not pseudocode:
            raise ValueError("No pseudocode generated")
        logger.info("Pseudocode generation successful")
        return pseudocode
    except requests.exceptions.RequestException as e:
        logger.error(f"Claude API request error: {e}")
        raise
    except Exception as e:
        logger.error(f"Error generating pseudocode: {e}")
        raise

def upload_to_s3(content, filename):
    try:
        s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=filename, Body=content.encode('utf-8'))
        logger.info(f"Uploaded {filename} to S3 bucket {S3_BUCKET_NAME}")
        return filename
    except ClientError as e:
        logger.error(f"Error uploading {filename} to S3: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error uploading to S3: {e}")
        raise
