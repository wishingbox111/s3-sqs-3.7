terraform {
  backend "s3" {
    bucket = "sctp-ce2-tfstate-bkt"
    key    = "chen-s3-sqs.tfstate"   #Change the value  of this to yourname-ecs-1.tfstate for  example
    region = "ap-southeast-1"
  }
}