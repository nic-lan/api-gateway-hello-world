import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

import unittest
import json
from main import lambda_handler


class TestLambdaHandler(unittest.TestCase):
    def test_lambda_handler(self):
        expected_result = {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
            },
            "body": json.dumps({"message": "Hello, world!"}),
        }

        # Call the function with dummy event and context
        result = lambda_handler({}, {})

        # Assert that the function returns the expected result
        self.assertEqual(result, expected_result)
