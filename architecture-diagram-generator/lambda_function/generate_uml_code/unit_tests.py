import unittest
from unittest.mock import patch, MagicMock
import lambda_function
import json

class TestGenerateUMLCode(unittest.TestCase):

    @patch('lambda_function.boto3.client')
    def test_lambda_handler_success(self, mock_boto3_client):
        # Mock the S3 client
        s3_mock = MagicMock()
        mock_boto3_client.return_value = s3_mock
        s3_mock.get_object.return_value = {
            'Body': MagicMock(read=MagicMock(return_value=b'function foo()\nfunction bar()\nfoo calls bar()'))
        }

        # Mock event
        event = {
            'body': json.dumps({'pseudocode_key': 'pseudocode.txt'})
        }

        response = lambda_function.lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 200)
        body = json.loads(response['body'])
        self.assertIn('uml_code_key', body)

    def test_generate_uml_code(self):
        pseudocode = "function foo()\nfunction bar()\nfoo calls bar()"
        uml_code = lambda_function.generate_uml_code(pseudocode)
        expected = "@startuml\nclass foo {\n}\nclass bar {\n}\nfoo --> bar\n@enduml"
        self.assertEqual(uml_code.strip(), expected.strip())

if __name__ == '__main__':
    unittest.main()
