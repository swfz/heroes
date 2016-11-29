variable "access_key" {
}
variable "secret_key" {
}
variable "region" {
  default = "ap-northeast-1"
}
variable "lambda_heroes" {
  type = "map"
  default = {
    search = "arn:aws:lambda:ap-northeast-1:680708571460:function:heroes_search"
    update = "arn:aws:lambda:ap-northeast-1:680708571460:function:heroes_update"
    delete = "arn:aws:lambda:ap-northeast-1:680708571460:function:heroes_delete"
  }
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_api_gateway_rest_api" "heroes" {
  name = "Heroes"
  description = "This is the Heroes API"
}

resource "aws_api_gateway_resource" "heroes-api" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  parent_id = "${aws_api_gateway_rest_api.heroes.root_resource_id}"
  path_part = "heroes"
}

output "lambda functions heroes search" {
  value = "${apex_function_heroes_search}"
}

# get
resource "aws_api_gateway_method" "heroes-api-get" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "heroes-api-get-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${lookup(var.lambda_heroes,"search")}/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
}
resource "aws_api_gateway_method_response" "heroes-api-get-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "heroes-api-get-integration-response" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
  status_code = "${aws_api_gateway_method_response.heroes-api-get-method-response.status_code}"
}
# put
resource "aws_api_gateway_method" "heroes-api-put" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "PUT"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "heroes-api-put-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "${aws_api_gateway_method.heroes-api-put.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${lookup(var.lambda_heroes,"update")}/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-put.http_method}"
}
# delete
resource "aws_api_gateway_method" "heroes-api-delete" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "DELETE"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "heroes-api-delete-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "${aws_api_gateway_method.heroes-api-delete.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${lookup(var.lambda_heroes,"delete")}/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-delete.http_method}"
}

resource "aws_api_gateway_deployment" "heroes-api-deploy" {
  depends_on = [
    "aws_api_gateway_method.heroes-api-get",
    "aws_api_gateway_method.heroes-api-put",
    "aws_api_gateway_method.heroes-api-delete"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  stage_name = "sample"
}

resource "aws_dynamodb_table" "sample-dynamo-table" {
  name = "SampleDynamoHeroes"
  read_capacity = 1
  write_capacity = 1
  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

# for tfstate
resource "aws_s3_bucket" "tf" {
  bucket = "heroes-terraform-statefile.com"
  acl = "private"
  tags {
    Name = "tfstate"
  }
}

# TODO
# sampleのS3配信
