output "role_arn" {
  value = aws_iam_role.dynamodb_autoscale_role.arn
}
output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}