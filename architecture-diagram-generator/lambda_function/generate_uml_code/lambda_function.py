import os
import json
import boto3
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Load configuration based on environment
try:
    ENV = os.environ.get('ENV', 'dev')
    if ENV == 'prod':
        from config.prod_config import S3_BUCKET_NAME
    else:
        from config.dev_config import S3_BUCKET_NAME
except ImportError as e:
    logger.error(f"Configuration import error: {e}")
    raise

# Initialize AWS S3 client
s3_client = boto3.client('s3')
def lambda_handler(event, context):
    try:
        # Get the pseudocode S3 key from the event
        pseudocode_key = event.get('pseudocode_key')
        if not pseudocode_key:
            raise ValueError("pseudocode_key not provided")

        pseudocode = download_from_s3(pseudocode_key)

        # Generate UML code
        uml_code = generate_uml_code(pseudocode)
        uml_code_file_key = upload_to_s3(uml_code, 'uml_code.puml')

        # Return the S3 key for the next function
        return {'uml_code_key': uml_code_file_key}

    except Exception as e:
        logger.error(f"Error in generate_uml_code: {e}")
        raise e

def download_from_s3(key):
    try:
        response = s3_client.get_object(Bucket=S3_BUCKET_NAME, Key=key)
        content = response['Body'].read().decode('utf-8')
        logger.info(f"Downloaded {key} from S3")
        return content
    except ClientError as e:
        logger.error(f"Error downloading {key} from S3: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error downloading from S3: {e}")
        raise

def generate_uml_code(pseudocode):
    try:
        uml_code = "@startuml\n"
        lines = pseudocode.split('\n')
        classes = set()
        relationships = []

        for line in lines:
            line = line.strip()
            if line.startswith('function'):
                function_name = line.split('function')[1].split('(')[0].strip()
                classes.add(function_name)
            elif 'calls' in line:
                parts = line.split('calls')
                caller = parts[0].split()[-1].strip()
                callee = parts[1].split('(')[0].strip()
                relationships.append((caller, callee))

        for cls in classes:
            uml_code += f"class {cls} {{\n}}\n"

        for rel in relationships:
            uml_code += f"{rel[0]} --> {rel[1]}\n"

        uml_code += "@enduml"
        logger.info("UML code generation successful")
        return uml_code
    except Exception as e:
        logger.error(f"Error generating UML code: {e}")
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
