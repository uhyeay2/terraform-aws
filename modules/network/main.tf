// ============================================================================
// Network Module
// Provides a reusable, environment‑agnostic VPC foundation including:
// - VPC
// - Subnet
// - Routing
// - Internet Gateway
// - Flow Logs (CloudWatch + KMS encryption)
// - Hardened default security group
// - Public security group for consumer modules
// ============================================================================

locals {
  // Standardized prefix for all resources.
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# CloudWatch Log Group (VPC Flow Logs)
# Encrypted with KMS and retains logs for 1 year (Checkov compliance)
# -----------------------------------------------------------------------------
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "KMS key for CloudWatch log group encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })

  tags = merge(
    {
      Name        = "${local.name_prefix}-cloudwatch-kms"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${local.name_prefix}-flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn

  tags = merge(
    {
      Name        = "${local.name_prefix}-vpc-flow-logs"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# -----------------------------------------------------------------------------
# IAM Role + Policy for VPC Flow Logs
# -----------------------------------------------------------------------------
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

resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  role       = aws_iam_role.vpc_flow_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# -----------------------------------------------------------------------------
# VPC Flow Logs
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Public Subnet
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.availability_zone

  // Public IPs should not be auto-assigned unless explicitly required.
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

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Public Route Table + Association
# -----------------------------------------------------------------------------
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

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Hardened Default Security Group
# Removes all default ingress/egress rules for a secure baseline
# -----------------------------------------------------------------------------
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = merge(
    {
      Name        = "${local.name_prefix}-default-sg"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

# -----------------------------------------------------------------------------
# Public Security Group (Reusable)
# Checkov skip: SG is intentionally not attached in this module
# -----------------------------------------------------------------------------
resource "aws_security_group" "public" {
  # checkov:skip=CKV2_AWS_5: "Security group intentionally defined for reuse by other modules"

  name        = "${local.name_prefix}-public-sg"
  description = "Security group for public-facing resources in the ${local.name_prefix} network."
  vpc_id      = aws_vpc.this.id

  // No ingress rules by default — consumer modules define them.

  egress {
    description = "Restrict outbound traffic to HTTPS only."
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
