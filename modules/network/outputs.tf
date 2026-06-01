// -----------------------------------------------------------------------------
// Outputs for the network module.
// -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "public_security_group_id" {
  description = "ID of the public security group for consumer modules."
  value       = aws_security_group.public.id
}

output "flow_log_group_name" {
  description = "Name of the CloudWatch log group used for VPC flow logs."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "kms_key_id" {
  description = "KMS key ID used for CloudWatch log group encryption."
  value       = aws_kms_key.cloudwatch_logs.key_id
}
