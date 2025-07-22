.PHONY: help init validate plan apply destroy fmt lint docs clean setup-tools

ENVIRONMENT ?= dev
ROOT_DIR = $(shell pwd)

help: ## Display this help message
	@echo "Usage: make [target] [ENVIRONMENT=dev|prod]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

setup-tools: ## Install required tools
	@echo "Installing pre-commit..."
	@pip install pre-commit
	@pre-commit install
	@echo "Installing TFLint..."
	@curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
	@echo "Installing terraform-docs..."
	@go install github.com/terraform-docs/terraform-docs@latest

init: ## Initialize Terraform
	@echo "Initializing Terraform for $(ENVIRONMENT)..."
	@terraform init -backend-config=environments/$(ENVIRONMENT)/backend.tf

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@terraform validate

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive .

lint: ## Run TFLint
	@echo "Running TFLint..."
	@tflint --recursive

docs: ## Generate documentation for Terraform modules
	@echo "Generating documentation..."
	@terraform-docs markdown table --output-file README.md --output-mode inject modules/azure-vnet

plan: init ## Create Terraform plan
	@echo "Creating Terraform plan for $(ENVIRONMENT)..."
	@terraform plan -var-file=environments/$(ENVIRONMENT)/terraform.tfvars -out=tfplan

apply: ## Apply Terraform changes
	@echo "Applying Terraform changes for $(ENVIRONMENT)..."
	@terraform apply -var-file=environments/$(ENVIRONMENT)/terraform.tfvars

destroy: ## Destroy Terraform resources
	@echo "WARNING: This will destroy all resources in $(ENVIRONMENT)!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy -var-file=environments/$(ENVIRONMENT)/terraform.tfvars; \
	fi

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@find . -type f -name "*.tfplan" -delete
	@find . -type f -name "*.tfstate*" -delete
	@find . -type f -name ".terraform.lock.hcl" -delete
	@find . -type d -name ".terraform" -exec rm -rf {} +

pre-commit: ## Run pre-commit checks
	@echo "Running pre-commit checks..."
	@pre-commit run --all-files

test-module: ## Test VNET module
	@echo "Testing VNET module..."
	@cd modules/azure-vnet && terraform test

security-scan: ## Run security scan with Checkov
	@echo "Running security scan..."
	@checkov -d . --framework terraform --quiet