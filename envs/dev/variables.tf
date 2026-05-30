// -----------------------------------------------------------------------------
// Development Environment Variables
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Provider Configuration
// -----------------------------------------------------------------------------
// The AWS region is defined at the environment level to ensure that each
// environment (dev, staging, prod) can specify its own region without affecting
// module reusability.
// -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region in which the development environment will be deployed."
  type        = string
}

// -----------------------------------------------------------------------------
// Network Configuration
// -----------------------------------------------------------------------------
// CIDR ranges and availability zones for the development environment. These
// values are passed directly into the network module to define the VPC and
// subnet layout.
// -----------------------------------------------------------------------------

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC used by the development environment."
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet. Must be a subset of the VPC CIDR."
  type        = string
}

// Availability zone is derived from the region (e.g., us-east-1a).
// This allows the environment to control placement without hard-coding AZs
// inside modules.
variable "availability_zone" {
  description = "Availability zone for the public subnet (e.g., us-east-1a)."
  type        = string
}

// -----------------------------------------------------------------------------
// Metadata and Tagging
// -----------------------------------------------------------------------------
// These values ensure consistent naming and tagging across all resources
// deployed within the development environment.
// -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project identifier used for naming and tagging resources."
  type        = string
}

variable "environment" {
  description = "Environment identifier (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources in the environment."
  type        = map(string)
  default     = {}
}
