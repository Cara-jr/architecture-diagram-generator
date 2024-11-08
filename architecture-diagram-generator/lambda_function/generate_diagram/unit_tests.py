import unittest
from unittest.mock import patch, MagicMock
import lambda_function
import json
import subprocess

class TestGenerateDiagram(unittest.TestCase):

    @patch('lambda_function.boto3.client')
    @patch('lambda_function.subprocess.run')
    def test_lambda_handler_success(self, mock_subprocess_run, mock_boto3_client):
        # Mock the S3 client
        s3_mock = MagicMock()
        mock_boto3_client.return_value = s3_mock
        s3_mock.get_object.return_value = {
            'Body': MagicMock(read=MagicMock(return_value=b'@startuml\nclass A\n@enduml'))
        }
        s3_mock.generate_presigned_url.return_value = 'https://presigned-url'

        # Mock event
        event = {
            'body': json.dumps({'uml_code_key': 'uml_code.puml'})
        }

        response = lambda_function.lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 200)
        body = json.loads(response['body'])
        self.assertIn('svg_diagram_url', body)

    @patch('lambda_function.subprocess.run')
    def test_generate_svg_diagram_failure(self, mock_subprocess_run):
        # Mock subprocess.run to raise an exception
        mock_subprocess_run.side_effect = subprocess.CalledProcessError(1, 'cmd')

        with self.assertRaises(Exception) as context:
            lambda_function.generate_svg_diagram('@startuml\nclass A\n@enduml')

        self.assertTrue('PlantUML subprocess error' in str(context.exception))

if __name__ == '__main__':
    unittest.main()
