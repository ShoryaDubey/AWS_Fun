import json

def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",  # match UI origin
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type,Authorization"
        },
        "body": json.dumps(body)
    }
