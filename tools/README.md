# **Infrastructure Tooling**

The `tools/` directory contains configuration files for static analysis, linting, and security scanning tools used throughout the Terraform project. These tools enforce best practices, maintain code quality, and ensure that infrastructure changes adhere to security and compliance standards.

By centralizing tool configuration in this directory, the project maintains a clean separation between **infrastructure code** and **infrastructure governance**.

---

## **Purpose**

This directory provides:

- **Consistent linting rules** across all modules and environments  
- **Automated security scanning** for Terraform resources  
- **Shared configuration** for local development, CI/CD pipelines, and pre‑commit hooks  
- **A single source of truth** for infrastructure quality controls  

These tools integrate with the project’s Makefile and pre‑commit configuration to create a smooth, automated workflow.

---

## **Contents**

```
tools/
│
├── checkov-config.yaml   # Security scanning configuration
└── tflint.hcl            # Terraform linting configuration
```

Each file is documented below.

---

## **Checkov Configuration** (`checkov-config.yaml`)

Checkov is a policy‑as‑code security scanner for Terraform.  
It analyzes Terraform resources for misconfigurations, insecure defaults, and violations of AWS best practices.

This configuration file:

- Enables all Terraform‑related Checkov checks  
- Scans both `modules/` and `envs/` directories  
- Suppresses checks that are not applicable to the current architecture  
- Provides a clean baseline for future expansion  

### Key Features

- **Framework selection**  
  Ensures only Terraform checks are executed.

- **Directory targeting**  
  Scans both modules and environment layers.

- **Selective rule suppression**  
  Skips checks related to:
  - NAT Gateways  
  - Load balancers  
  - S3 buckets  
  - RDS  
  - VPC Flow Logs (initial baseline only)

These suppressions can be removed as the architecture evolves.

---

## **TFLint Configuration** (`tflint.hcl`)

TFLint is a Terraform linter that enforces best practices, detects errors, and validates AWS‑specific configurations.

This configuration file:

- Enables the AWS ruleset plugin  
- Enforces naming conventions  
- Detects unused variables and deprecated syntax  
- Validates required providers  
- Ensures typed variables  
- Checks EC2 instance types for validity  

### Key Features

- **Global Terraform rules**  
  Ensures code quality and consistency across modules.

- **AWS‑specific rules**  
  Validates resource types and region compatibility.

- **Naming enforcement**  
  Requires `snake_case` naming for Terraform identifiers.

This configuration helps maintain a clean, predictable codebase as the project grows.

---

## **Integration With the Workflow**

These tools are integrated into:

- **Makefile**  
  - `make lint` → runs TFLint  
  - `make scan` → runs Checkov  

- **Pre‑commit hooks**  
  - Automatically run before every commit  
  - Prevent insecure or invalid code from entering the repository  

This ensures that every change is:

- Formatted  
- Validated  
- Linted  
- Security‑scanned  

before it ever reaches version control.

---

## **Future Enhancements/Extensions Under Consideration**

As the architecture evolves, this directory may include:

- Additional Checkov suppressions or custom policies  
- Custom TFLint rules  
- tfsec configuration  
- OPA/Rego policies  
- CI/CD‑specific tool configs  

The structure is intentionally simple and scalable.