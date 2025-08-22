import boto3
import json
import os

ses = boto3.client("ses")
SENDER_EMAIL = os.environ["SENDER_EMAIL"]  # Verified email in SES

def recevingOrder(event, context):
    for record in event["Records"]:
        # Parse order from SQS
        order = json.loads(record["body"])
        
        # Add delivery status
        order["status"] = "delivered"
        
        # Ensure emailId exists
        if "emailId" in order and order["emailId"]:
            subject = f"Order {order['orderId']} Update"
            body = f"""
            Hello,
            
            Your order has been processed!
            
            Order ID: {order['orderId']}
            Item: {order['item']}
            Status: {order['status']}
            
            Thank you for ordering with us.
            """
            
            # Send email via SES
            ses.send_email(
                Source=SENDER_EMAIL,
                Destination={
                    "ToAddresses": [order["emailId"]]
                },
                Message={
                    "Subject": {"Data": subject},
                    "Body": {"Text": {"Data": body}}
                }
            )
            print(f"Email sent to {order['emailId']} for order {order['orderId']}")
        else:
            print("No emailId provided in order message")

    return {"statusCode": 200}
