data "aws_canonical_user_id" "current" {}

//alb_log
resource "aws_s3_bucket" "alb_log" {
  bucket = local.s3.alb_log_bucket

  # acl
  grant {
    id          = data.aws_canonical_user_id.current.id
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }

  grant {
    id          = local.AWS.S3.S3_CANONICAL_USER_ID_AWSLOGS_DELIVERY
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }

  hosted_zone_id = local.AWS.S3.S3_AP_HOSTED_ZONE_ID

  request_payer = "BucketOwner"

  versioning {
    enabled    = "false"
    mfa_delete = "false"
  }

  tags = {
    Name : "${local.project}"
  }
}


resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.s3_alb_log_policy.json
}


data "aws_iam_policy_document" "s3_alb_log_policy" {
  # "Id": "AWSConsole-AccessLogs-Policy-1491817904669",
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.s3.alb_log_bucket}/alb-main/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.AWS.ALB.AP_ACCOUNT_ID}:root"]
    }
  }
}