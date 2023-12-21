provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    region = "us-east-1"
  }
}

module "s3" {
  source          = "./modules/s3"
  project_tag     = var.project_tag
  name_prefix     = var.name_prefix
}

module "s3-2" {
  source          = "./modules/s3"
  project_tag     = "${var.project_tag}-2"
  name_prefix     = "${var.name_prefix}-2"
}

module "s3-3" {
  source          = "./modules/s3"
  project_tag     = "${var.project_tag}-3"
  name_prefix     = "${var.name_prefix}-3"
}

module "s3-4" {
  source          = "./modules/s3"
  project_tag     = "${var.project_tag}-4"
  name_prefix     = "${var.name_prefix}-4"
}

module "cloudfront" {
  source                         = "./modules/cloudfront"
  s3_frontend                    = [
      {domain_name = module.s3.s3_frontend, origin_id = "${var.name_prefix}-origin", path_pattern = "/1"}, 
      {domain_name = module.s3-2.s3_frontend, origin_id = "${var.name_prefix}-2-origin", path_pattern = "/2"}, 
      {domain_name = module.s3-3.s3_frontend, origin_id = "${var.name_prefix}-3-origin", path_pattern = "/3"}, 
      {domain_name = module.s3-4.s3_frontend, origin_id = "${var.name_prefix}-4-origin", path_pattern = "/4"}, 
    ]
  cloudfront_certificate_arn     = var.cloudfront_certificate_arn
  hosted_zone_names              = [var.hosted_zone_name, var.hosted_zone_name_2, var.hosted_zone_name_3, var.hosted_zone_name_4]
  project_tag                    = var.project_tag
  name_prefix                    = var.name_prefix
}

module "route53" {
  source                               = "./modules/route53"
  hosted_zone_name                     = var.hosted_zone_name
  resource_domain_name                 = module.cloudfront.s3_frontend_distribution.domain_name
  resource_hosted_zone                 = module.cloudfront.s3_frontend_distribution.hosted_zone_id
  zone_id                              = var.zone_id
  project_tag                          = var.project_tag
  name_prefix                          = var.name_prefix
}

module "route53-2" {
  source                               = "./modules/route53"
  hosted_zone_name                     = var.hosted_zone_name_2
  resource_domain_name                 = module.cloudfront.s3_frontend_distribution.domain_name
  resource_hosted_zone                 = module.cloudfront.s3_frontend_distribution.hosted_zone_id
  zone_id                              = var.zone_id
  project_tag                          = "${var.project_tag}-2"
  name_prefix                          = "${var.name_prefix}-2"
}

module "route53-3" {
  source                               = "./modules/route53"
  hosted_zone_name                     = var.hosted_zone_name_3
  resource_domain_name                 = module.cloudfront.s3_frontend_distribution.domain_name
  resource_hosted_zone                 = module.cloudfront.s3_frontend_distribution.hosted_zone_id
  zone_id                              = var.zone_id
  project_tag                          = "${var.project_tag}-3"
  name_prefix                          = "${var.name_prefix}-3"
}

module "route53-4" {
  source                               = "./modules/route53"
  hosted_zone_name                     = var.hosted_zone_name_4
  resource_domain_name                 = module.cloudfront.s3_frontend_distribution.domain_name
  resource_hosted_zone                 = module.cloudfront.s3_frontend_distribution.hosted_zone_id
  zone_id                              = var.zone_id
  project_tag                          = "${var.project_tag}-4"
  name_prefix                          = "${var.name_prefix}-4"
}