variable "region" {
  description = "AWS Region to deploy to"
  default     = "us-west-2"
}

data "aws_ssm_parameter" "kubecost_license_id" {
  name = "platform-enterprise-kubecost-license"
}

data "aws_caller_identity" "current" {}

variable "cluster_id" {
  description = "Name for the EKS clutser - e.g. dev,staging"
  default     = "test"
}

module "kubecost" {
  source                          = "../"
  license                         = data.aws_ssm_parameter.kubecost_license_id.value
  primary_cluster                 = false
  federated_storage_bucket_name   = "kubecost-poc-2024-03"
  federated_storage_bucket_region = "us-west-2"
  kubecost_version                = "2.2.0"
  cluster_id                      = var.cluster_id
  namespace                       = "cost"
}
