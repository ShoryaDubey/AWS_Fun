resource "aws_dynamodb_table" "orders" {
  name         = "CustomerOrders"
  billing_mode = "PAY_PER_REQUEST"  # stays in free tier
  hash_key     = "email"            # Partition key
  range_key    = "orderId"          # Sort key

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "orderId"
    type = "S"
  }

  tags = {
    Environment = "Test"
    Project     = "PizzaApp"
  }
}
