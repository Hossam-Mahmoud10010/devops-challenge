provider "aws" {
  region = "us-east-1"
}

#terraform {
#  backend "s3" {
#    bucket         = "tfstate-hossam10010-devops-challenge"
#    dynamodb_table = "tfstate-hossam10010-devops-challenge"
#    key            = "devops-challenge.tfstate" # the key inside the bucket
#    region         = "us-east-1"
#    encrypt        = true
#  }
#}
