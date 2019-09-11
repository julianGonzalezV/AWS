provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "example1_js" {
  function_name = "ServerlessExample"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "terraform-serverless-example"
  s3_key    = "v1.0.0/lambda_ex1.zip"

  # "MainJs" is the filename within the zip file (MainJs.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "MainJs.handler"
  runtime = "nodejs10.x"

  role = "${aws_iam_role.lambda_exec.arn}"
}

# IAM(Identity and Access Management) role which dictates what other AWS services the Lambda function
# may access, es decir que evita/restringe que use otros servicios que no se encuentren acà 
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"
  
# note como se usa eof para crear un bloque de String en varias lineas
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}