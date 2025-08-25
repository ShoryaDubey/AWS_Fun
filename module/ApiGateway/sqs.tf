resource "aws_sqs_queue" "orders_deadletter" {
  name = "terraform-example-queue-dlq"
}

resource "aws_sqs_queue" "orders" {
  name                      = "terraform-example-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.orders_deadletter.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "production"
  }
}

resource "aws_iam_role_policy" "producer_lambda_policy" {
  name = "producer-lambda-sqs-policy"
  role = aws_iam_role.producer_lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.orders.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "consumer_policy" {
  name = "consumer-sqs-policy"
  role = aws_iam_role.consumer_lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" = "Allow",
        "Action" = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ],
      "Resource" = aws_sqs_queue.orders.arn
      }
    ]
  })
}
