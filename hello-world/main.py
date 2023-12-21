import json

def lambda_handler(_event, _context):
    return {
        'statusCode': 200,
        'headers': {
          'Content-Type': 'application/json',
        },
        'body': json.dumps({'message': 'Hello, world!'})
    }
