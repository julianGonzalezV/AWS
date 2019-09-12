provider "aws" {
  region = "us-east-1"
}

# Note como no agregamos ningun valor quemado, en este caso es super util para que desde consola de comandos
# Podamos intercambiar las versiones que deseamos
variable "app_version" {
}
resource "aws_lambda_function" "example1_js" {
  function_name = "ServerlessExample"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "jag-terraform-serverless-example1"
  s3_key    = "v${var.app_version}/lambda_ex1.zip"

  # "MainJs" is the filename within the zip file (MainJs.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "MainJs.handler"
  runtime = "nodejs10.x"

  role = "${aws_iam_role.lambda_exec.arn}"
}

# IAM(Identity and Access Management) role which dictates what other AWS services the Lambda function
# may access, es decir que evita/restringe que use otros servicios que no se encuentren en esta seccion
# note como se usa eof para crear un bloque de String en varias lineas
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"
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
# Se trata de que el lambda que creemos de permisos de invocacion a esta al api gateway 
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.example1_js.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api_ex1.execution_arn}/*/*"
}