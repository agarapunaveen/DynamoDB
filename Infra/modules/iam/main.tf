resource "aws_iam_role" "dynamodb_autoscale_role" {
  name = "DynamoDBAutoScalingRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "application-autoscaling.amazonaws.com"
      }
    }]
  })
}

# Attach an inline policy with correct permissions
resource "aws_iam_policy" "dynamodb_autoscaling_policy" {
  name        = "DynamoDBAutoScalingPolicy"
  description = "Policy to allow DynamoDB auto scaling actions"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:SetAlarmState",
          "application-autoscaling:PutScalingPolicy",
          "application-autoscaling:DeleteScalingPolicy",
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:DescribeScalingActivities",
          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:RegisterScalableTarget"
        ]
        Resource = "*"
      }
    ]
  })
}

# # Attach Policy to Role
# resource "aws_iam_role_policy_attachment" "dynamodb_autoscale_policy" {
#   role       = aws_iam_role.dynamodb_autoscale_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSApplicationAutoScalingDynamoDBTable"
# }

# Attach the inline policy to the role
resource "aws_iam_role_policy_attachment" "dynamodb_autoscale_policy_attach" {
  role       = aws_iam_role.dynamodb_autoscale_role.name
  policy_arn = aws_iam_policy.dynamodb_autoscaling_policy.arn
}

# stream iam roles

resource "aws_iam_role" "lambda_execution_role" {
  name = "DynamoDBStreamLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "lambda_dynamodb_stream" {
  name        = "LambdaDynamoDBStreamPolicy"
  description = "Policy for Lambda to read DynamoDB streams"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "dynamodb:DescribeStream",
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:ListStreams"
      ]
      Resource = var.dynamodb_stream_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_stream_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_stream.arn
}
