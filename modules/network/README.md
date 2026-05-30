# **Network Module**

The **Network module** provisions a minimal, production‑ready AWS networking foundation. It creates a VPC, a public subnet, routing components, security groups, and optional observability features such as VPC Flow Logs. The module is intentionally **region‑agnostic**, allowing environments (e.g., dev, staging, prod) to supply their own AWS region, availability zones, and CIDR ranges.

This module is designed to serve as a **baseline network layer** for workloads that require internet connectivity while maintaining security best practices and clear separation of concerns.

---

## **Features**

- VPC with DNS support and hostnames enabled  
- Public subnet in a user‑specified availability zone  
- Internet Gateway and public route table  
- Route table association for outbound internet access  
- Hardened default security group  
- Public security group for internet‑facing workloads  
- Optional VPC Flow Logs for auditing and troubleshooting  
- Consistent tagging and naming conventions  
- Clean separation between module logic and environment configuration  

---

## **Module Structure**

The module is organized into logical regions for clarity and maintainability:

- **Locals** — naming conventions and computed values  
- **Core resources** — VPC, subnet, IGW, route table, associations  
- **Security resources** — default SG lockdown, public SG  
- **Observability resources** — VPC Flow Logs, IAM roles, log groups  
- **Inputs** — defined in `variables.tf`  
- **Outputs** — defined in `outputs.tf`  

This structure ensures the module remains easy to extend and reason about.

---

## **Usage Example**

Below is an example of how an environment (e.g., `envs/dev/main.tf`) consumes this module:

```hcl
provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../../modules/network"

  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_block  = "10.0.1.0/24"
  availability_zone         = "${var.aws_region}a"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}
```

---

## **Inputs**

| Variable | Type | Description |
|---------|------|-------------|
| `vpc_cidr_block` | string | CIDR block for the VPC. |
| `public_subnet_cidr_block` | string | CIDR block for the public subnet. |
| `availability_zone` | string | Availability zone for the public subnet. |
| `project_name` | string | Project identifier used for naming and tagging. |
| `environment` | string | Environment name (dev, staging, prod). |
| `tags` | map(string) | Additional tags applied to all resources. |
| `enable_dns_support` | bool | Enables DNS support in the VPC. |
| `enable_dns_hostnames` | bool | Enables DNS hostnames in the VPC. |

---

## **Outputs**

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the VPC. |
| `public_subnet_id` | ID of the public subnet. |
| `public_route_table_id` | ID of the public route table. |
| `internet_gateway_id` | ID of the Internet Gateway. |
| `public_security_group_id` | ID of the public security group. |
| `vpc_flow_log_id` | ID of the VPC Flow Log resource. |

---

## **Security Considerations**

- The default security group is explicitly locked down to prevent unintended traffic.  
- The public security group contains **no ingress rules** by default; consuming modules must define them intentionally.  
- Outbound traffic is restricted to HTTPS (443) by default to reduce exposure.  
- Flow logs can be enabled to support auditing and incident response.  

---

## **Design Philosophy**

This module follows these principles:

- **Region‑agnostic** — no hard‑coded region or AZ assumptions  
- **Environment‑driven** — environment layer controls region, CIDRs, and workload‑specific rules  
- **Secure by default** — no permissive ingress, restricted egress, hardened default SG  
- **Composable** — outputs expose only what downstream modules need  
- **Predictable naming** — consistent tagging and naming conventions via `name_prefix`  

---

## **Future Enhancements/Extensions Under Consideration**

- Adding private subnets  
- NAT Gateways for outbound private traffic  
- Additional route tables  
- ALB/NLB integration  
- VPC endpoints for AWS services  
- Multi‑AZ expansion  

Note: The module is intentionally minimal to serve as a clean foundation.