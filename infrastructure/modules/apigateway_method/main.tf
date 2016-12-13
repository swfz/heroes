data "aws_caller_identity" "current" { }
variable "rest_api_id" {}
variable "resource_id" {}
variable "region" {}
variable "lambda_name" {}
variable "method" {}
variable "api_name" {}

resource "aws_api_gateway_method" "apigateway-method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${var.resource_id}"
  http_method   = "${var.method}"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "apigateway-method-integration" {
  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${var.resource_id}"
  http_method             = "${aws_api_gateway_method.apigateway-method.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_name}/invocations"
  integration_http_method = "${aws_api_gateway_method.apigateway-method.http_method}"
}

resource "aws_lambda_permission" "with-apigateway" {
  statement_id  = "${var.resource_id}-${var.method}"
  function_name = "${var.lambda_name}"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.rest_api_id}/prod/${var.method}/${var.api_name}"
}

