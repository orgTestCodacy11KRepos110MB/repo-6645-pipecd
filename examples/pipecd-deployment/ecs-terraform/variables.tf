data "aws_caller_identity" "current" {}
//AWS CONSTS
locals {
  AWS = {
    S3 = {
      S3_AP_HOSTED_ZONE_ID                  = "Z2M4EHUR26P7ZW"
      S3_CANONICAL_USER_ID_AWSLOGS_DELIVERY = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    }
    ALB = {
      AP_ACCOUNT_ID = "582318560864"
    }
  }
}


//export
locals {
  project = "namba-pipecd-control-plane"
  redis = {
    node_type = "cache.t2.micro"
  }

  rds = {
    node_type = "db.t3.micro"
  }

  s3 = { # These must be unique in the world.
    alb_log_bucket = "${local.project}-alb-log"
    config_bucket  = "${local.project}-config"
  }

  ssm = {
    path_to_encryption_key = "/${local.project}/encryption-key"
  }

}

// common
locals {
  // リソースタグで変わらないもの
  basicTags = {
    Product = "${local.project}"
  }

  // コスト分析の際のグルーピング
  componentType = {
    computing       = { "CostComponentType" = "Computing" }
    storage         = { "CostComponentType" = "Storage" }
    database        = { "CostComponentType" = "Database" }
    networking      = { "CostComponentType" = "Networking" }
    queue           = { "CostComponentType" = "Queue" }
    operation       = { "CostComponentType" = "Operation" }
    other           = { "CostComponentType" = "Other" }
    storageDatabase = { "CostComponentType" = "Storage_Database" }
  }
}