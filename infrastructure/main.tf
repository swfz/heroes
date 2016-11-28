variable "access_key" {
}
variable "secret_key" {
}
variable "region" {
  default = "ap-northeast-1"
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
resource "aws_api_gateway_method" "heroes-api-get" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "GET"
  authorization = "NONE"
}

# TODO fix uri
resource "aws_api_gateway_integration" "heroes-api-get-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${apex_function_heroes_search}:current/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-get.http_method}"
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

resource "aws_s3_bucket" "tf" {
  bucket = "heroes-terraform-statefile.com"
  acl = "private"
  tags {
    Name = "tfstate"
  }
}

