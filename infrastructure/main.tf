data "aws_caller_identity" "current" { }

variable "access_key" {
}
variable "secret_key" {
}
variable "region" {
  default = "ap-northeast-1"
}
variable "lambda_iam_role_name" {
}
variable "lambda_names" {
  default = {}
}

output "rolename" {
  value = "${var.lambda_iam_role_name}"
}

output "tfvars-lookup" {
  value = "lookup: ${lookup(var.lambda_names,"search")}"
}

output "tfvars" {
  value = "brackets: ${var.lambda_names[search]}"
}

resource "aws_iam_policy_attachment" "heroes-policy-1" {
  name = "lambda_policy_dynamo_execution"
  roles = [ "${var.lambda_iam_role_name}", "lambda_dynamo_streams" ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_api_gateway_rest_api" "heroes" {
  name        = "heroes"
  description = "This is the Heroes API"
}

resource "aws_api_gateway_resource" "heroes-api" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  parent_id   = "${aws_api_gateway_rest_api.heroes.root_resource_id}"
  path_part   = "heroes"
}

module "api_gateway_method_get" {
  source      = "./modules/apigateway_method"
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  api_name    = "${aws_api_gateway_rest_api.heroes.id}"
  region      = "${var.region}"
  lambda_name = "${lookup(var.lambda_names,"search")}"
  method      = "GET"
}
module "api_gateway_method_put" {
  source      = "./modules/apigateway_method"
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  api_name    = "${aws_api_gateway_rest_api.heroes.id}"
  region      = "${var.region}"
  lambda_name = "${lookup(var.lambda_names,"update")}"
  method      = "PUT"
}
module "api_gateway_method_post" {
  source      = "./modules/apigateway_method"
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  api_name    = "${aws_api_gateway_rest_api.heroes.id}"
  region      = "${var.region}"
  lambda_name = "${lookup(var.lambda_names,"update")}"
  method      = "POST"
}
module "api_gateway_method_delete" {
  source      = "./modules/apigateway_method"
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  api_name    = "${aws_api_gateway_rest_api.heroes.id}"
  region      = "${var.region}"
  lambda_name = "${lookup(var.lambda_names,"delete")}"
  method      = "DELETE"
}

module "apigateway_cors-option" {
  source = "./modules/apigateway_cors"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
}


resource "aws_api_gateway_deployment" "heroes-api-deploy" {
#  depends_on = [
#    "module.api_gateway_method_get",
#    "aws_api_gateway_method.heroes-api-get",
#    "aws_api_gateway_method.heroes-api-put",
#    "aws_api_gateway_method.heroes-api-post",
#    "aws_api_gateway_method.heroes-api-delete"
#  ]
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  stage_name = "prod"
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

