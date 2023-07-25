# from https://registry.terraform.io/providers/-/aws/latest/docs/resources/sqs_queue_policy

locals {
    name_prefix = "enchen"
}

# to create queue first

data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service" #original is : "*"
      identifiers = ["s3.amazonaws.com"] #original is: ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:${local.name_prefix}2-s3tosqs"] #original code: ["arn:aws:sqs:*:*:s3-event-notification-queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }
  }
}

#doing the resources queue

resource "aws_sqs_queue" "queue" {
  name   = "${local.name_prefix}2-s3tosqs" # to add local.name_prefix and don't need to add the enchen here.This is the name of SQS queue name.
  policy = data.aws_iam_policy_document.queue.json # this depends policy document
}

#if there is a cyclic dependency issue - is need a policy to create the queue...>?


resource "aws_s3_bucket" "bucket" {
  bucket = "${local.name_prefix}-trigger-bucket" # bucket name created 
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*","s3:ObjectRemoved:*"]
    #filter_suffix = ".log" # don't need this line
  }
}