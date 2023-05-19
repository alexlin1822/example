# Define provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create security group
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "My security group"
  vpc_id      = aws_vpc.my_vpc.id

  # Ingress rule to allow incoming SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow outgoing traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM role
resource "aws_iam_role" "my_lambda_role" {
  name = "my-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach IAM policy to the role
resource "aws_iam_policy_attachment" "my_lambda_policy_attachment" {
  name       = "my-lambda-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.my_lambda_role.name]
}

# Create Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  function_name    = "my-lambda-function"
  role             = aws_iam_role.my_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 10
  memory_size      = 128
  vpc_config {
    subnet_ids         = ["subnet-12345678", "subnet-abcdefgh"]  # Replace with actual subnet IDs
    security_group_ids = [aws_security_group.my_security_group.id]
  }

  # Specify the Python deployment package (ZIP or S3 bucket)
  # For example, if using a local ZIP file:
  # filename         = "lambda_function.zip"
  # source_code_hash = filebase64sha256("lambda_function.zip")
}
