# AWS_Fun

Users place food orders via an API (/order).

The order gets pushed to SQS.

A Lambda Worker picks the order, marks it as “preparing/delivered” in DynamoDB.

Once status is updated → SNS sends user a notification (email or SMS).
