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

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.orders.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowProducerSend",
        Effect    = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_exec.arn
        },
        Action    = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ],
        Resource  = aws_sqs_queue.orders.arn
      },
      {
        Sid       = "AllowConsumerReceive",
        Effect    = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_exec.arn
        },
        Action    = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ],
        Resource  = aws_sqs_queue.orders.arn
      }
    ]
  })
}
