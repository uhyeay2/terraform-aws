// outputs.tf
// -----------------------------------------------------------------------------
// Outputs for the network module.
// These values are consumed by environment configurations and other modules.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Core network outputs
// -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC created by this module."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

// -----------------------------------------------------------------------------
// Security outputs
// -----------------------------------------------------------------------------

output "public_security_group_id" {
  description = "ID of the public security group."
  value       = aws_security_group.public.id
}

// -----------------------------------------------------------------------------
// Observability outputs
// -----------------------------------------------------------------------------

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log resource."
  value       = aws_flow_log.vpc.id
}
