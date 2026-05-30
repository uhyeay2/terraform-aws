# ------------------------------------------------------------------------------
# TFLint configuration for enforcing Terraform best practices and AWS-specific
# linting rules.
# ------------------------------------------------------------------------------

config {
  call_module_type    = "all"       # Inspect all module types (local, registry, Git)
  force               = false       # Do not continue execution on internal errors
  disabled_by_default = false       # Enable rules unless explicitly disabled
}

plugin "aws" {
  enabled = true                    # Enable AWS ruleset plugin
  version = "0.30.0"                # AWS ruleset version
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

###################################
# Global rule settings
###################################

rule "terraform_unused_declarations" {
  enabled = true                    # Detect unused variables, locals, and outputs
}

rule "terraform_deprecated_interpolation" {
  enabled = true                    # Warn when using legacy interpolation syntax ("${...}")
}

rule "terraform_typed_variables" {
  enabled = true                    # Ensure variables include explicit type constraints
}

rule "terraform_required_providers" {
  enabled = true                    # Validate required_providers block is properly defined
}

rule "terraform_naming_convention" {
  enabled = true                    # Enforce naming standards for resources, variables, etc.
  format  = "snake_case"            # Require snake_case naming convention
}

###################################
# AWS-specific rules
###################################

rule "aws_instance_invalid_type" {
  enabled = true                    # Validate EC2 instance types are valid for the region
}
