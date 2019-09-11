# The rest API is the container for all of the other API Gateway objects we will create.
resource "aws_api_gateway_rest_api" "api_ex1" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example One"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api_ex1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_ex1.root_resource_id}"
  # path_part con el signo +  dice al proxy a que reciba o haga match con cualquier tipo de request
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_ex1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  # ANY: Este man le dice que recibe cualquier tipo de peticion rest get, post etc
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.api_ex1.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  # AWS_PROXY hace que api gateway pueda llamar a otra api de aws, en esta caso el API de aws labmda y hacer una invocación 
  # de la lambda function
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.example1_js.invoke_arn}"
}


# El recurso creado arriba "aws_api_gateway_method" "proxy" NO ES capaz de encontrar o reponder ante un Path vacío , imagine 
# que es algo así como que usted no coloca toda la url de un sitio y el lo lleva al componente raiz, por lo anterior se debe
# crear un proxy root igual-identico a proxy que se crea en la línea 14

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_ex1.id}"
  resource_id   = "${aws_api_gateway_rest_api.api_ex1.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.api_ex1.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.example1_js.invoke_arn}"
}

# finalmente se crea el despliegue del api gateway
resource "aws_api_gateway_deployment" "example_deployment1" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api_ex1.id}"
  stage_name  = "test"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.example_deployment1.invoke_url}"
}

