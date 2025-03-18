output "dynamodb_arn" {
  value = aws_dynamodb_table.custom_table.arn
}
output "dynamodb_stream_arn" {
  value = aws_dynamodb_table.custom_table.stream_arn
}