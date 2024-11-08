import os
import json
import boto3
import logging
import subprocess
import tempfile
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
        # Get the UML code S3 key from the event
        uml_code_key = event.get('uml_code_key')
        if not uml_code_key:
            raise ValueError("uml_code_key not provided")

        uml_code = download_from_s3(uml_code_key)

        # Generate SVG diagram
        svg_diagram = generate_svg_diagram(uml_code)
        svg_diagram_file_key = upload_to_s3(svg_diagram, 'diagram.svg', is_binary=True)

        # Generate presigned URLs
        pseudocode_url = generate_presigned_url('pseudocode.txt')
        uml_code_url = generate_presigned_url('uml_code.puml')
        svg_diagram_url = generate_presigned_url(svg_diagram_file_key)

        # Return the URLs to the client
        return {
            'pseudocode_url': pseudocode_url,
            'uml_code_url': uml_code_url,
            'svg_diagram_url': svg_diagram_url
        }

    except Exception as e:
        logger.error(f"Error in generate_diagram: {e}")
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

def generate_svg_diagram(uml_code):
    try:
        # Use PlantUML to generate SVG diagram
        with tempfile.NamedTemporaryFile(delete=False, suffix='.puml') as temp_uml_file:
            temp_uml_file.write(uml_code.encode('utf-8'))
            uml_file_path = temp_uml_file.name

        # Generate SVG using PlantUML
        plantuml_jar_path = '/opt/plantuml.jar'  # Path to PlantUML jar in Lambda layer
        svg_output_path = uml_file_path.replace('.puml', '.svg')

        subprocess.run([
            'java', '-Djava.awt.headless=true', '-jar', plantuml_jar_path, '-tsvg', uml_file_path
        ], check=True)

        with open(svg_output_path, 'rb') as svg_file:
            svg_content = svg_file.read()
        logger.info("SVG diagram generation successful")
        return svg_content
    except subprocess.CalledProcessError as e:
        logger.error(f"PlantUML subprocess error: {e}")
        raise
    except Exception as e:
        logger.error(f"Error generating SVG diagram: {e}")
        raise

def upload_to_s3(content, filename, is_binary=False):
    try:
        if is_binary:
            s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=filename, Body=content)
        else:
            s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=filename, Body=content.encode('utf-8'))
        logger.info(f"Uploaded {filename} to S3 bucket {S3_BUCKET_NAME}")
        return filename
    except ClientError as e:
        logger.error(f"Error uploading {filename} to S3: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error uploading to S3: {e}")
        raise

def generate_presigned_url(file_key):
    try:
        url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': S3_BUCKET_NAME, 'Key': file_key},
            ExpiresIn=3600
        )
        logger.info(f"Generated presigned URL for {file_key}")
        return url
    except ClientError as e:
        logger.error(f"Error generating presigned URL for {file_key}: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error generating presigned URL: {e}")
        raise
