provider "aws" {
  region = "us-east-1"  # Change as needed
}

resource "aws_dynamodb_table" "custom_table" {
  name         = "dev-table"

  read_capacity  = 5  # Set custom read capacity
  write_capacity = 5  # Set custom write capacity

  attribute {
    name = "partition_key"
    type = "S"  # String type; can be "N" for Number or "B" for Binary
  }

  attribute {
    name = "sort_key"
    type = "N"  # Number type; can be "S" or "B"
  }

  hash_key  = "partition_key"  # Partition key
  range_key = "sort_key"       # Sort key (optional)

  # Attributes for GSI and LSI
  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "N"
  }

   local_secondary_index {
    name               = "LSI_CreatedAt"
    range_key          = "created_at"
    projection_type    = "ALL"  # Stores all attributes
  }

  global_secondary_index {
    name               = "GSI_Email"
    hash_key           = "email"
    projection_type    = "ALL"  # Stores all attributes
    read_capacity      = 5
    write_capacity     = 5
  }

 # Enable DynamoDB Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"  # Options: NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY

  tags = {
    Name        = "MyCustomDynamoDBTable"
    Environment = "Dev"
  }
}


resource "aws_dynamodb_table_item" "custom_item" {
  table_name = aws_dynamodb_table.custom_table.name

  hash_key   = "partition_key"
  range_key  = "sort_key"

  item = <<ITEM
{
  "partition_key": { "S": "user_001" },
  "sort_key": { "N": "1001" },
  "name": { "S": "Alice" },
  "age": { "N": "25" },
  "city": { "S": "Los Angeles" },
  "ttl": { "N": "1735689600" } 
}
ITEM
}



# Application Auto Scaling Target for Read Capacity
resource "aws_appautoscaling_target" "read_target" {
  max_capacity       = 20  # Maximum Read Capacity
  min_capacity       = 5   # Minimum Read Capacity
  resource_id        = "table/${aws_dynamodb_table.custom_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
  role_arn           = var.role_arn
}

# Application Auto Scaling Target for Write Capacity
resource "aws_appautoscaling_target" "write_target" {
  max_capacity       = 10  # Maximum Write Capacity
  min_capacity       = 5   # Minimum Write Capacity
  resource_id        = "table/${aws_dynamodb_table.custom_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
  role_arn           = var.role_arn
}

# Auto Scaling Policy for Read Capacity
resource "aws_appautoscaling_policy" "read_policy" {
  name               = "DynamoDBReadAutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value       = 70.0  # Scale up/down at 70% utilization
    scale_in_cooldown  = 60   # Wait time before scaling down
    scale_out_cooldown = 60   # Wait time before scaling up
  }
}


# Auto Scaling Policy for Write Capacity
resource "aws_appautoscaling_policy" "write_policy" {
  name               = "DynamoDBWriteAutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}