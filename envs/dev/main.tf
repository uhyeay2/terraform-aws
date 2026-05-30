// -----------------------------------------------------------------------------
// Development Environment Configuration
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Provider Configuration
// -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

// -----------------------------------------------------------------------------
// Local Values
// -----------------------------------------------------------------------------
// Environment-specific naming conventions and shared metadata.
// These values help maintain consistent naming across all resources deployed
// within the development environment.
// -----------------------------------------------------------------------------

locals {
  environment = var.environment
}

// -----------------------------------------------------------------------------
// Network Module
// -----------------------------------------------------------------------------
// Instantiates the reusable network module, providing the foundational VPC,
// subnet, routing, and security group configuration for the development
// environment. All region-specific and environment-specific values are passed
// in from this layer.
// -----------------------------------------------------------------------------

module "network" {
  source = "../../modules/network"

  // Network CIDR configuration
  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block

  // Availability zone selection for the public subnet
  availability_zone = "${var.aws_region}a"

  // Metadata and tagging
  project_name = var.project_name
  environment  = local.environment
  tags         = var.tags

  // VPC feature toggles
  enable_dns_support   = true
  enable_dns_hostnames = true
}

