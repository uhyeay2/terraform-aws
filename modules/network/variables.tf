// variables.tf
// -----------------------------------------------------------------------------
// Input variables for the network module.
// These variables allow the module to remain region-agnostic and reusable across
// multiple environments (dev, staging, prod).
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Network configuration
// -----------------------------------------------------------------------------

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet. Must be a subset of the VPC CIDR."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone in which the public subnet will be created."
  type        = string
}

// -----------------------------------------------------------------------------
// Metadata and tagging
// -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used for tagging and naming resources."
  type        = string
}

variable "environment" {
  description = "Environment identifier (e.g., dev, staging, prod)."
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

// -----------------------------------------------------------------------------
// VPC feature toggles
// -----------------------------------------------------------------------------

variable "enable_dns_support" {
  description = "Enable DNS support for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC."
  type        = bool
  default     = true
}
