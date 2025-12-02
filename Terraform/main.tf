module "networking" {
  source = "./modules/networking"
  vpc_cidr = var.vpc_cidr
  private_subnetA_cidr = var.private_subnetA_cidr
  private_subnetB_cidr = var.private_subnetB_cidr
  public_subnetA_cidr = var.public_subnetA_cidr
  public_subnetB_cidr = var.public_subnetB_cidr
}

module "storage" {
  source = "./modules/storage"
  efs_security_group_id = module.networking.efs_sg_id
  private_subnetA_id = module.networking.private_subnetA_id
  private_subnetB_id = module.networking.private_subnetB_id
}

module "loadbalancer" {
    source = "./modules/loadbalancer"
    alb_security_group_id = module.networking.alb_security_group_id
    public_subnetA_id = module.networking.public_subnetA_id
    public_subnetB_id = module.networking.public_subnetB_id
    vpc_id = module.networking.vpc_id
}

module "iam" {
  source = "./modules/iam"
  efs_arn = module.storage.efs_arn
  codestar_connection_arn = module.cicd.codestar_connection_arn
  codepipeline_bucket = module.storage.codepipeline_bucket
}

module "containers" {
  source = "./modules/containers"
  asg_arn = module.compute.asg_arn
  public_subnetA_id = module.networking.public_subnetA_id
  public_subnetB_id = module.networking.public_subnetB_id
  target_group_arn = module.loadbalancer.tg_arn
  efs_id = module.storage.efs_id
  efs_ap_id = module.storage.efs_ap_id
  exec_role_arn = module.iam.exec_role_arn
  task_role_arn = module.iam.task_role_arn
  instance_security_group_id = module.networking.instance_security_group_id
}

module "compute" {
  source = "./modules/compute"
  ecs_instance_profile_name = module.iam.ecs_instance_profile_name
  public_subnetA_id = module.networking.public_subnetA_id
  public_subnetB_id = module.networking.public_subnetB_id
  instance_security_group_id = module.networking.instance_security_group_id
}

module "cicd" {
  source = "./modules/cicd"
  codepipeline_role_arn = module.iam.codepipeline_role_arn
  codepipeline_bucket = module.storage.codepipeline_bucket
  codebuild_role_arn = module.iam.codebuild_role_arn
}
