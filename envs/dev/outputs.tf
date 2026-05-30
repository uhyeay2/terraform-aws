// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
// Expose key network attributes for use by future modules (e.g., compute,
// load balancers, databases). These outputs make it easy to reference the
// network layer without tightly coupling modules.
// -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC created for the development environment."
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet created for the development environment."
  value       = module.network.public_subnet_id
}

output "public_security_group_id" {
  description = "ID of the public security group for internet-facing workloads."
  value       = module.network.public_security_group_id
}

output "public_route_table_id" {
  description = "ID of the public route table used for outbound internet access."
  value       = module.network.public_route_table_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = module.network.internet_gateway_id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log resource for auditing and monitoring."
  value       = module.network.vpc_flow_log_id
}
