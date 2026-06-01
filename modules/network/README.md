# 📘 **Network Module**

A reusable Terraform module that provisions a secure, production‑ready AWS network foundation.  
This module is designed to be **environment‑agnostic**, **CIS‑aligned**, and **Checkov‑clean**, providing:

- A VPC with DNS support  
- Public subnet  
- Internet gateway  
- Routing  
- Hardened default security group  
- Public security group for consumer modules  
- VPC Flow Logs with **KMS encryption** and **1‑year retention**  
- Clean tagging strategy  

---

## 🏗️ **Architecture Overview**

```
┌───────────────────────────────────────────────────────────────┐
│                           AWS VPC                             │
│                     (DNS support enabled)                     │
│                                                               │
│  ┌──────────────────────────────┐     ┌────────────────────┐  │
│  │        Public Subnet         │     │  Default SG (deny) │  │
│  │  - No auto-assign public IP  │     └────────────────────┘  │
│  │  - Routed to IGW             │                             │
│  └───────────────┬──────────────┘                             │
│                  │                                            │
│        ┌─────────▼─────────┐                                  │
│        │ Internet Gateway  │                                  │
│        └───────────────────┘                                  │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │                   VPC Flow Logs                          │ │
│  │  - CloudWatch Log Group (KMS encrypted)                  │ │
│  │  - IAM Role + Policy                                     │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ Public Security Group (reusable)                         │ │
│  │  - No ingress rules (consumer-defined)                   │ │
│  │  - Egress restricted to HTTPS                            │ │
│  └──────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

---

## 🚀 **Features**

- **Secure by default**  
  - Default SG denies all traffic  
  - Public SG has no ingress rules  
  - Egress restricted to HTTPS only  

- **Logging & Compliance**  
  - VPC Flow Logs enabled  
  - CloudWatch Log Group encrypted with **KMS**  
  - Log retention set to **365 days** (Checkov compliant)  

- **Modular & Reusable**  
  - Public SG intentionally not attached (consumer modules attach it)  
  - Clean outputs for easy integration  

- **Tagging**  
  - All resources support custom tags  
  - Standardized naming convention  

---

## 📦 **Module Usage**

```hcl
module "network" {
  source = "./modules/network"

  project_name              = "myapp"
  environment               = "dev"
  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_block  = "10.0.1.0/24"
  availability_zone         = "us-east-1a"

  tags = {
    Owner = "platform-team"
    CostCenter = "1234"
  }
}
```

---

## 🔧 **Inputs**

| Variable | Type | Description | Required |
|---------|------|-------------|----------|
| `project_name` | string | Project/application name | Yes |
| `environment` | string | Environment (dev/staging/prod) | Yes |
| `vpc_cidr_block` | string | CIDR block for the VPC | Yes |
| `public_subnet_cidr_block` | string | CIDR block for public subnet | Yes |
| `availability_zone` | string | AZ for the subnet | Yes |
| `enable_dns_support` | bool | Enable VPC DNS support | No (default: true) |
| `enable_dns_hostnames` | bool | Enable VPC DNS hostnames | No (default: true) |
| `tags` | map(string) | Additional tags | No |

---

## 📤 **Outputs**

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the VPC |
| `public_subnet_id` | ID of the public subnet |
| `public_security_group_id` | ID of the reusable public SG |
| `flow_log_group_name` | CloudWatch log group name |
| `kms_key_id` | KMS key ID used for log encryption |

---

## 🔐 **Security Considerations**

- Default SG is fully locked down  
- Public SG has **no ingress rules** by design  
- Flow logs are encrypted with a dedicated KMS key  
- HTTPS-only egress reduces attack surface  

---

## 🧪 **Checkov Compliance**

This module passes the following policies:

- **CKV_AWS_158** — CloudWatch Log Group encrypted with KMS  
- **CKV_AWS_338** — Log retention ≥ 1 year  
- **CKV2_AWS_5** — SG intentionally unused (skip annotation included)  

---