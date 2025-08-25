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
        
        # Ensure email exists
        if "email" in order and order["email"]:
            subject = f"Order Update - {order.get('item', 'Unknown Item')}"
            body = f"""
            Hello {order.get('customerName', '')},
            
            Your order has been processed!
            
            Item: {order['item']}
            Quantity: {order.get('quantity', 1)}
            Status: {order['status']}
            
            Thank you for ordering with us.
            """
            
            # Send email via SES
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
            print(f"Email sent to {order['email']} for {order['item']}")
        else:
            print("No email provided in order message")

    return {"statusCode": 200}
