resource "aws_iam_role" "producer_lambda_exec" {
  name = "producer-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "get_lambda_exec" {
  name = "get-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role" "consumer_lambda_exec" {
  name = "consumer-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "orders-lambda-logs"
  roles      = [aws_iam_role.producer_lambda_exec.name, 
                aws_iam_role.consumer_lambda_exec.name,
                aws_iam_role.get_lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ses" {
  role       = aws_iam_role.consumer_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.producingOrder.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.orders_api.execution_arn}/*/POST/order"
}

resource "aws_lambda_permission" "getorder_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getOrder.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.orders_api.execution_arn}/*/GET/order/*"

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

resource "aws_iam_role_policy" "GetItem_policy" {
  name = "get_lambda_Dynamo_getItem"
  role = aws_iam_role.get_lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.orders.arn
      },
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
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.orders.arn
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ],
        Resource = aws_sqs_queue.orders.arn
      }
    ]
  })
}
