import os
import json
import boto3

sqs = boto3.client("sqs")
queue_url = os.environ.get("SQS_QUEUE_URL")

def handler(event, context):
    try:
        # Parse body if using API Gateway proxy integration
        body = event.get("body")
        if isinstance(body, str):
            body = json.loads(body)

        # Send to SQS
        resp = sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(body)
        )

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": "Order sent",
                "MessageId": resp["MessageId"]
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }
