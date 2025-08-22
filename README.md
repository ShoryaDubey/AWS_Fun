# AWS_Fun

Users place food orders via an API (/order).

The order gets pushed to SQS.

A Lambda Worker picks the order, marks it as “preparing/delivered” in DynamoDB.

Once status is updated → SNS sends user a notification (email or SMS).
<img width="699" height="321" alt="Untitled Diagram drawio (1)" src="https://github.com/user-attachments/assets/e5378436-9c20-48bc-908f-e42993bf996a" />
