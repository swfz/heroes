data "aws_caller_identity" "current" { }
variable "rest_api_id" {}
variable "resource_id" {}
variable "region" {}
variable "lambda_name" {}
variable "method" {}
variable "api_name" {}

resource "aws_api_gateway_method" "heroes-api-get" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${var.method}"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "heroes-api-get-integration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_name}/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
}

resource "aws_lambda_permission" "heroes-with-apigateway-get" {
  statement_id = "api-heroes-permission-get"
  action = "lambda:InvokeFunction"
  function_name = "heroes_search"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.rest_api_id}/prod/${var.method}/${var.api_name}"
}

