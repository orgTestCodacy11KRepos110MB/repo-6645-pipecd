module "vpc" {
  source  = "./vpc"
  project = local.project
  tags    = merge(local.basicTags, local.componentType.networking)
}

module "alb" {
  source                 = "./alb"
  project                = local.project
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = [module.vpc.subnet_public_a_id, module.vpc.subnet_public_c_id]
  access_log_bucket_name = local.s3.alb_log_bucket
  tags                   = merge(local.basicTags, local.componentType.networking)
  depends_on             = [module.vpc]
}

module "redis" {
  source                  = "./redis"
  project                 = local.project
  node_type               = local.redis.node_type
  subnet_ids              = [module.vpc.subnet_public_a_id]
  vpc_id                  = module.vpc.vpc_id
  redis_subnet_group_name = module.vpc.redis_subnet_group_name
  tags                    = merge(local.basicTags, local.componentType.storage)
  depends_on              = [module.vpc]
}

module "rds" {
  source               = "./rds"
  project              = local.project
  node_type            = local.rds.node_type
  db_subnet_group_name = module.vpc.db_subnet_group_name
  vpc_id               = module.vpc.vpc_id
  depends_on           = [module.vpc]
}

module "ecs" {
  source                  = "./ecs"
  project                 = local.project
  tags                    = merge(local.basicTags, local.componentType.networking)
  vpc_id                  = module.vpc.vpc_id
  gateway_image_url       = "envoyproxy/envoy-alpine:v1.18.3"
  server_image_url        = "ghcr.io/pipe-cd/pipecd:v0.41.3"
  ops_image_url           = "ghcr.io/pipe-cd/pipecd:v0.41.3"
  subnet_id               = module.vpc.subnet_public_a_id
  log_group_name          = aws_cloudwatch_log_group.pipecd-main.name
  lb_target_group_arn     = module.alb.lb_target_groups.arn
  db_instance_address     = module.rds.db_instance_address
  redis_host              = module.redis.redis_host
  db_security_group_id    = module.rds.aws_security_group_id
  redis_security_group_id = module.redis.aws_security_group_id
  config_bucket_name      = local.s3.config_bucket
  filestore_bucket_name = local.s3.filestore_bucket
  path_to_encryption_key  = local.ssm.path_to_encryption_key
  depends_on              = [module.alb, module.rds, module.redis]
}

module "ec2" {
  source               = "./ec2"
  db_security_group_id = module.rds.aws_security_group_id
  subnet_id            = module.vpc.subnet_public_a_id
  vpc_id               = module.vpc.vpc_id
  depends_on           = [module.alb, module.rds]
}