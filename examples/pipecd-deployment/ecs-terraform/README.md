# Example for deploy control-plane to Amazon ECS

## Prepare
1. Make a s3 bucket for terraform backend
Write bucket name to `00-main.tf`
```
terraform {
  backend "s3" {
    bucket  = "example-pipecd-control-plane-tfstate" #your bucket name for terraform backend
    region  = "ap-northeast-1"
    key     = "tfstate"
    profile = "pipecd-control-planeg-terraform" #your profile
  }
  required_providers {
    aws = {
      version = "~> 3.34.0"
    }
  }
}
```
2. Make a s3 bucket for filestore and write the bucket name for it to `control-plane-config.yaml`
```
apiVersion: "pipecd.dev/v1beta1"
kind: ControlPlane
spec:
    datastore:
    type: MYSQL
    config:
        url: root:test@tcp(pipecd-mysql:3306)
        database: quickstart
    filestore:
    type: S3
    config: # edit here
        bucket: example-pipecd-control-plane-filestore 
        region: ap-northeast-1
    projects:
    - id: quickstart
        staticAdmin:
        username: hello-pipecd
        passwordHash: "$2a$10$ye96mUqUqTnjUqgwQJbJzel/LJibRhUnmzyypACkvrTSnQpVFZ7qK" # bcrypt value of "hello-pipecd"
```

3. Write config of RDS for datastore to `control-plane-config.yaml`
Note: Do not edit hostname (pipecd-mysql) because it will be edited autimaticaly by terraform.
```
apiVersion: "pipecd.dev/v1beta1"
kind: ControlPlane
spec:
    datastore:
    type: MYSQL
    config: # edit here
        url: root:test@tcp(pipecd-mysql:3306)
        database: quickstart
    filestore:
    type: S3
    config: 
        bucket: example-pipecd-control-plane-filestore 
        region: ap-northeast-1
    projects:
    - id: quickstart
        staticAdmin:
        username: hello-pipecd
        passwordHash: "$2a$10$ye96mUqUqTnjUqgwQJbJzel/LJibRhUnmzyypACkvrTSnQpVFZ7qK" # bcrypt value of "hello-pipecd"
```

4. Edit `variables.tf` for your project
```
locals {
  project = "namba-pipecd-control-plane" # edit here
  redis = {
    node_type = "cache.t2.micro"
  }

  rds = {
    node_type = "db.t3.micro"
  }

  s3 = { # These must be unique in the world.
    alb_log_bucket = "${local.project}-alb-log"
    config_bucket  = "${local.project}-config" # edit here
  }

  ssm = {
    path_to_encryption_key = "/${local.project}/encryption-key"
  }
}
```

5. Make a s3 bucket for config file and write bucket name to `variables.tf`
```
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
    config_bucket  = "${local.project}-config" # edit here
  }

  ssm = {
    path_to_encryption_key = "/${local.project}/encryption-key"
  }
}
```

5. Put config files in the s3 bucket you made at step 3 
The path must be under root.
```
/control-plane-config.yaml
/envoy-config.yaml
```

6. Put encryption key in parameter store and write the path to `variables.tf`
```
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
    path_to_encryption_key = "/${local.project}/encryption-key" # edit here
  }
}
```

## Deploy
```
terraform apply
```

