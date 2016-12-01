# heroes

## Component
- apex
- terraform
- lambda
- api gateway
- s3
- angular2

## deploy

- infrastructure/credentials.tfvars

```
#AWS Settings
access_key = "xxxxxxxxxxxxxxxxxxx"
secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
region = "ap-northeast-1"
```

```
AWS_DEFAULT=ap-northeast-1 apex -p ${aws_profile} -r ap-northeast-1 infra plan --var-file credentials.tfvars
```

