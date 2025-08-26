import boto3
import json
import os
import uuid

# Clients
ses = boto3.client("ses")
dynamodb = boto3.resource("dynamodb")

# Environment variables
SENDER_EMAIL = os.environ["SENDER_EMAIL"]  # Verified email in SES
TABLE_NAME = os.environ["DYNAMO_TABLE"]    # DynamoDB table name

def handler(event, context):
    table = dynamodb.Table(TABLE_NAME)

    for record in event["Records"]:
        # Parse order from SQS
        order = json.loads(record["body"])
        
        # Generate unique orderId
        order["orderId"] = str(uuid.uuid4())
        
        # Add delivery status
        order["status"] = "delivered"
        
        # Ensure email exists
        if "email" in order and order["email"]:
            subject = f"Order Update - {order.get('item', 'Unknown Item')}"
            body = f"""
            Hello {order.get('customerName', '')},
            
            Your order has been processed!
            
            Order ID: {order['orderId']}
            Item: {order['item']}
            Quantity: {order.get('quantity', 1)}
            Status: {order['status']}
            
            You can use the Order ID to track your order.
            
            Thank you for ordering with us.
            """
            
            # ✅ Send email via SES
            ses.send_email(
                Source=SENDER_EMAIL,
                Destination={
                    "ToAddresses": [order["email"]]
                },
                Message={
                    "Subject": {"Data": subject},
                    "Body": {"Text": {"Data": body}}
                }
            )
            print(f"Email sent to {order['email']} for {order['item']} (Order ID: {order['orderId']})")
            
            # ✅ Save order to DynamoDB
            table.put_item(Item=order)
            print(f"Order saved to DynamoDB: {order['orderId']} - {order['email']} - {order['item']}")
        
        else:
            print("No email provided in order message")

    return {"statusCode": 200}
