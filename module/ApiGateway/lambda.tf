resource "aws_lambda_function" "recevingOrder" {
  filename         = "lambda.zip"
  function_name    = "recevingOrder"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("lambda.zip")   
  runtime = "python3.9"

  tags = {
    Environment = "dev"
    Application = "example"
  }
}