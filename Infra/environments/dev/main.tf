module "dynamodb" {
  source = "../../modules/dynamodb"
  role_arn = module.iam.role_arn
}
module "iam" {
  source = "../../modules/iam"
  dynamodb_stream_arn = module.dynamodb.dynamodb_stream_arn
}
module "lambda"{
  source = "../../modules/lambda"
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn
  dynamodb_stream_arn = module.dynamodb.dynamodb_stream_arn
}