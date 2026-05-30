// -----------------------------------------------------------------------------
// Network module
// Provides a baseline VPC, subnet, routing, and security group configuration.
// Designed to be region-agnostic and reusable across multiple environments.
// -----------------------------------------------------------------------------

locals {
  // Standardized name prefix applied to all resources managed by this module.
  // Example: tf-learning-dev
  name_prefix = "${var.project_name}-${var.environment}"
}

// VPC definition.
// Provides an isolated virtual network with DNS support and hostnames enabled
// to support public-facing workloads.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      Name        = "${local.name_prefix}-vpc"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

// CloudWatch Log Group for VPC flow logs.
// Stores network flow records for analysis, troubleshooting, and security auditing.
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${local.name_prefix}-flow-logs"
  retention_in_days = 30

  tags = merge(
    {
      Name        = "${local.name_prefix}-vpc-flow-logs"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

// IAM role for VPC flow logs.
// Grants VPC Flow Logs permission to publish logs to CloudWatch Logs.
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${local.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    {
      Name        = "${local.name_prefix}-vpc-flow-logs-role"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

// IAM policy attachment for VPC flow logs role.
// Allows the role to write flow logs to CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  role       = aws_iam_role.vpc_flow_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

// VPC flow log configuration.
// Captures all traffic (accepted and rejected) for the VPC and publishes to CloudWatch Logs.
resource "aws_flow_log" "vpc" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn

  tags = merge(
    {
      Name        = "${local.name_prefix}-vpc-flow-log"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

// Public subnet.
// Located in a single availability zone and configured to assign public IP
// addresses to instances launched within it.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  
  # Public subnets should not automatically assign public IPs unless required.
  # Best practice is to let the EC2 instance or ENI decide whether it needs public IP
  map_public_ip_on_launch = false 
                                  

  tags = merge(
    {
      Name        = "${local.name_prefix}-public-subnet"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "public"
    },
    var.tags
  )
}

// Internet Gateway.
// Provides a target for internet-bound traffic from the public subnet.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name        = "${local.name_prefix}-igw"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

// Public route table.
// Routes outbound traffic from the public subnet to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    {
      Name        = "${local.name_prefix}-public-rt"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "public"
    },
    var.tags
  )
}

// Association between the public subnet and the public route table.
// Ensures that instances in the public subnet use the internet route.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

// Default security group hardening.
// Overrides the default VPC security group to deny all inbound and outbound traffic,
// ensuring that only explicitly defined security groups are used for workloads.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  // Remove all default ingress rules.
  ingress = []

  // Remove all default egress rules.
  egress = []

  tags = merge(
    {
      Name        = "${local.name_prefix}-default-sg"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

// Security group for public-facing workloads.
// Intended for use by resources that require inbound access from the internet.
// Specific ingress rules should be defined by the consuming environment or
// compute module to avoid over-permissive defaults.
resource "aws_security_group" "public" {
  name        = "${local.name_prefix}-public-sg"
  description = "Security group for public-facing resources in the ${local.name_prefix} network."
  vpc_id      = aws_vpc.this.id

  // No ingress rules are defined here by default to avoid overly broad access.
  // Ingress rules should be added in the consuming module or environment
  // according to workload requirements.

  egress {
    description = "Restrict outbound traffic to only what is required."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${local.name_prefix}-public-sg"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "public"
    },
    var.tags
  )
}
