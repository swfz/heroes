data "aws_caller_identity" "current" { }

variable "access_key" {
}
variable "secret_key" {
}
variable "region" {
  default = "ap-northeast-1"
}
variable "lambda_iam_role_name" {
  # apex側で自動で生成されるrole名
  default = "heroes_lambda_function"
}
variable "lambda_names" {
  type = "map"
  default = {
    search = "heroes_search"
    update = "heroes_update"
    delete = "heroes_delete"
  }
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_iam_policy_attachment" "heroes-policy-1" {
  name = "lambda_policy_dynamo_execution"
  roles = [ "${var.lambda_iam_role_name}" ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_api_gateway_rest_api" "heroes" {
  name = "heroes"
  description = "This is the Heroes API"
}

resource "aws_api_gateway_resource" "heroes-api" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  parent_id = "${aws_api_gateway_rest_api.heroes.root_resource_id}"
  path_part = "heroes"
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
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${lookup(var.lambda_names,"search")}/invocations"
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

resource "aws_lambda_permission" "heroes-with-apigateway-get" {
  statement_id = "api-heroes-permission-get"
  action = "lambda:InvokeFunction"
  function_name = "heroes_search"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.heroes.id}/prod/GET/heroes"
}

resource "aws_lambda_event_source_mapping" "heroes-get-mapping" {
  event_source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.heroes.id}/prod/GET/heroes"
  enabled = true
  starting_position = "LATEST"
  function_name = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${lookup(var.lambda_names,"search")}"
}

# put
#resource "aws_api_gateway_method" "heroes-api-put" {
#  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
#  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
#  http_method = "PUT"
#  authorization = "NONE"
#}
#resource "aws_api_gateway_integration" "heroes-api-put-integration" {
#  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
#  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
#  http_method = "${aws_api_gateway_method.heroes-api-put.http_method}"
#  type = "AWS_PROXY"
#  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${lookup(var.lambda_names,"update")}/invocations"
#  integration_http_method = "${aws_api_gateway_method.heroes-api-put.http_method}"
#}
## delete
#resource "aws_api_gateway_method" "heroes-api-delete" {
#  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
#  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
#  http_method = "DELETE"
#  authorization = "NONE"
#}
#resource "aws_api_gateway_integration" "heroes-api-delete-integration" {
#  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
#  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
#  http_method = "${aws_api_gateway_method.heroes-api-delete.http_method}"
#  type = "AWS_PROXY"
#  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${lookup(var.lambda_names,"delete")}/invocations"
#  integration_http_method = "${aws_api_gateway_method.heroes-api-delete.http_method}"
#}

resource "aws_api_gateway_deployment" "heroes-api-deploy" {
  depends_on = [
    "aws_api_gateway_method.heroes-api-get",
#    "aws_api_gateway_method.heroes-api-put",
#    "aws_api_gateway_method.heroes-api-delete"
  ]
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

