# ------------------------------------------------------------------------------
# Makefile for Terraform Infrastructure Workflows
# ------------------------------------------------------------------------------
# Provides a consistent interface for formatting, linting, validating, security
# scanning, planning, and applying Terraform configurations across environments.
# This Makefile is environment-agnostic and can be used from any env directory.
# ------------------------------------------------------------------------------

# Default environment directory (can be overridden: `make plan ENV=staging`)
ENV ?= dev
TF_DIR := envs/$(ENV)

# ------------------------------------------------------------------------------
# Formatting & Validation
# ------------------------------------------------------------------------------

# Format all Terraform files recursively.
fmt:
    terraform fmt -recursive

# Validate Terraform configuration in the selected environment.
validate:
    cd $(TF_DIR) && terraform validate

# ------------------------------------------------------------------------------
# Linting & Security Scanning
# ------------------------------------------------------------------------------

# Run TFLint using the project's configuration.
lint:
    tflint --config=tools/tflint.hcl

# Run Checkov using the project's configuration file.
scan:
    checkov --config-file tools/checkov-config.yaml

# ------------------------------------------------------------------------------
# Terraform Lifecycle Commands
# ------------------------------------------------------------------------------

# Initialize Terraform in the selected environment.
init:
    cd $(TF_DIR) && terraform init

# Generate and display an execution plan.
plan: init
    cd $(TF_DIR) && terraform plan -var-file=terraform.tfvars

# Apply the Terraform configuration.
deploy: init
    cd $(TF_DIR) && terraform apply -var-file=terraform.tfvars

# Destroy all resources in the environment.
destroy: init
    cd $(TF_DIR) && terraform destroy -var-file=terraform.tfvars

# ------------------------------------------------------------------------------
# Utility Commands
# ------------------------------------------------------------------------------

# Remove Terraform local state files (use with caution).
clean:
    find . -type f -name "*.tfstate*" -delete
    rm -rf .terraform .terraform.lock.hcl

# Display available commands.
help:
    @echo ""
    @echo "Available commands:"
    @echo "  make fmt        - Format Terraform files"
    @echo "  make validate   - Validate Terraform configuration"
    @echo "  make lint       - Run TFLint"
    @echo "  make scan       - Run Checkov security scan"
    @echo "  make init       - Initialize Terraform"
    @echo "  make plan       - Generate Terraform plan"
    @echo "  make deploy     - Apply Terraform configuration"
    @echo "  make destroy    - Destroy Terraform-managed resources"
    @echo "  make clean      - Remove local Terraform state"
    @echo ""
    @echo "Use ENV=<env> to target a different environment (default: dev)"
    @echo "Example: make plan ENV=prod"
