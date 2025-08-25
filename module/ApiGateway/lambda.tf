resource "aws_lambda_function" "recevingOrder" {
  filename         = "recevingOrder_function.zip"
  function_name    = "recevingOrder"
  handler          = "recevingOrder_function.recevingOrder"
  role             = aws_iam_role.consumer_lambda_exec.arn
  source_code_hash = filebase64sha256("recevingOrder_function.zip")   
  runtime = "python3.9"

  environment {
    variables = {
      SENDER_EMAIL = "shorya@gmail.com" 
    }
  }

  tags = {
    Environment = "dev"
    Application = "example"
  }
}


resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.orders.arn
  function_name    = aws_lambda_function.recevingOrder.arn
  batch_size       = 1
  enabled          = true
}

resource "aws_lambda_function" "producingOrder" {
  filename         = "producingOrder_function.zip"
  function_name    = "producingOrder"
  handler          = "producingOrder_function.handler"
  role             = aws_iam_role.producer_lambda_exec.arn
  source_code_hash = filebase64sha256("producingOrder_function.zip")   
  runtime = "python3.9"

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.orders.id
    }
  }

  tags = {
    Environment = "dev"
    Application = "example"
  }
}