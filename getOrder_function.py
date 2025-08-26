import boto3
import json
import os
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["DYNAMO_TABLE"]

# Helper to convert Decimal to int/float
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            # Convert Decimals to int if no fraction, else float
            if obj % 1 == 0:
                return int(obj)
            else:
                return float(obj)
        return super(DecimalEncoder, self).default(obj)

def handler(event, context):
    table = dynamodb.Table(TABLE_NAME)
    
    try:
        # orderId from path, email from query string
        order_id = event.get("pathParameters", {}).get("orderId")
        email = event.get("queryStringParameters", {}).get("email")

        if not email or not order_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Both 'email' and 'orderId' are required"})
            }

        # Query DynamoDB
        response = table.get_item(
            Key={"email": email, "orderId": order_id}
        )
        
        if "Item" not in response:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "Order not found"})
            }

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps(response["Item"], cls=DecimalEncoder)
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
