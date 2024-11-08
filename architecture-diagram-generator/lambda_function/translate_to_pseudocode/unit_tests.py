import unittest
from unittest.mock import patch, MagicMock
import lambda_function
import os

class TestTranslateToPseudocode(unittest.TestCase):

    @patch('lambda_function.requests.post')
    @patch('lambda_function.boto3.client')
    def test_lambda_handler_success(self, mock_boto3_client, mock_requests_post):
        # Mock the S3 client
        s3_mock = MagicMock()
        mock_boto3_client.return_value = s3_mock

        # Mock the Claude API response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'completion': 'pseudocode content'}
        mock_requests_post.return_value = mock_response

        # Mock event
        event = {
            'body': base64.b64encode(b'print("Hello World")').decode('utf-8'),
            'isBase64Encoded': True
        }

        response = lambda_function.lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 200)
        body = json.loads(response['body'])
        self.assertIn('pseudocode_key', body)

    @patch('lambda_function.requests.post')
    def test_generate_pseudocode_failure(self, mock_requests_post):
        # Mock the Claude API to raise an exception
        mock_requests_post.side_effect = Exception('API error')

        with self.assertRaises(Exception) as context:
            lambda_function.generate_pseudocode('/path/to/nonexistent/file')

        self.assertTrue('Error generating pseudocode' in str(context.exception))

if __name__ == '__main__':
    unittest.main()
