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

resource "aws_lambda_permission" "heroes-with-apigateway-get" {
  statement_id = "api-heroes-permission-get"
  action = "lambda:InvokeFunction"
  function_name = "heroes_search"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.heroes.id}/prod/GET/heroes"
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
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${lookup(var.lambda_names,"update")}/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-put.http_method}"
}
resource "aws_lambda_permission" "heroes-with-apigateway-put" {
  statement_id = "api-heroes-permission-put"
  action = "lambda:InvokeFunction"
  function_name = "heroes_update"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.heroes.id}/prod/PUT/heroes"
}
# post
resource "aws_api_gateway_method" "heroes-api-post" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "heroes-api-post-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.heroes.id}"
  resource_id = "${aws_api_gateway_resource.heroes-api.id}"
  http_method = "${aws_api_gateway_method.heroes-api-post.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${lookup(var.lambda_names,"update")}/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-post.http_method}"
}
resource "aws_lambda_permission" "heroes-with-apigateway-post" {
  statement_id = "api-heroes-permission-post"
  action = "lambda:InvokeFunction"
  function_name = "heroes_update"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.heroes.id}/prod/POST/heroes"
}

## delete
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
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${lookup(var.lambda_names,"update")}/invocations"
  integration_http_method = "${aws_api_gateway_method.heroes-api-delete.http_method}"
}
resource "aws_lambda_permission" "heroes-with-apigateway-delete" {
  statement_id = "api-heroes-permission-delete"
  action = "lambda:InvokeFunction"
  function_name = "heroes_update"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.heroes.id}/prod/DELETE/heroes"
}

resource "aws_api_gateway_deployment" "heroes-api-deploy" {
  depends_on = [
    "aws_api_gateway_method.heroes-api-get",
    "aws_api_gateway_method.heroes-api-put",
    "aws_api_gateway_method.heroes-api-post",
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

