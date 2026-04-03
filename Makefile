# Makefile for Terraform Operations

.PHONY: help init plan apply destroy validate fmt clean output module-*

help:
	@echo "Terraform Operations"
	@echo "===================="
	@echo "  make init         - Initialize Terraform & modules"
	@echo "  make plan         - Generate and save plan"
	@echo "  make apply        - Apply Terraform configuration"
	@echo "  make destroy      - Destroy all resources"
	@echo "  make validate     - Validate configuration"
	@echo "  make fmt          - Format all Terraform files"
	@echo ""
	@echo "Module Operations"
	@echo "================="
	@echo "  make module-list  - List all modules"
	@echo "  make module-get   - Download module dependencies"
	@echo ""
	@echo "State & Utilities"
	@echo "================="
	@echo "  make outputs      - Display all outputs"
	@echo "  make show-state   - List resources in state"
	@echo "  make clean        - Clean state and lock files"
	@echo ""
	@echo "Testing"
	@echo "======="
	@echo "  make check        - Verify prerequisites"
	@echo "  make kubeconfig   - Configure kubectl"
	@echo ""
	@echo "Diagnostic"
	@echo "=========="
	@echo "  make cost         - Show cost estimate (requires infracost)"

init:
	terraform init

plan:
	terraform plan -out=tfplan
	@echo "Plan saved to tfplan"
	terraform show tfplan > deployment_plan.txt
	@echo "Plan details saved to deployment_plan.txt"

apply:
	terraform apply tfplan

destroy:
	@echo "WARNING: This will destroy all resources in the resource group!"
	@read -p "Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		terraform destroy; \
	else \
		echo "Destroy cancelled"; \
	fi

validate:
	terraform validate

fmt:
	terraform fmt -recursive

# Module Operations
module-list:
	@echo "Available modules in modules/ directory:"
	@ls -d modules/*/ | sed 's#modules/##g; s#/##g' | sort

module-get:
	terraform get -update
	@echo "Module dependencies downloaded/updated"

module-validate:
	@for module in modules/*/; do \
		echo "Validating $$module..."; \
		(cd $$module && terraform init -upgrade > /dev/null 2>&1 && terraform validate) || echo "ERROR in $$module"; \
	done

clean:
	rm -f tfplan tfplan.lock.hcl
	rm -f deployment_plan.txt
	rm -rf .terraform
	rm -f .terraform.lock.hcl

outputs:
	@terraform output

cost:
	@command -v infracost >/dev/null 2>&1 || { echo "infracost not installed. Install from https://www.infracost.io"; exit 1; }
	infracost breakdown --path .

show-state:
	terraform state list

show-resource:
	@read -p "Enter resource name: " resource; \
	terraform state show $$resource

refresh:
	terraform refresh

workspace-list:
	terraform workspace list

workspace-new:
	@read -p "Enter workspace name: " ws; \
	terraform workspace new $$ws

# Testing targets
test-sql:
	@read -p "Enter SQL Server FQDN: " fqdn; \
	mysql -h $$fqdn -u sqladmin -p

test-redis:
	@read -p "Enter Redis Hostname: " host; \
	redis-cli -h $$host -p 6380 --tls ping

test-storage:
	@read -p "Enter Storage Account Name: " account; \
	curl https://$$account.blob.core.windows.net/

kubeconfig:
	@RG=$$(terraform output -raw resource_group_name); \
	AKS=$$(terraform output -raw aks_cluster_name); \
	az aks get-credentials --resource-group $$RG --name $$AKS --admin

check:
	@echo "Checking prerequisites..."
	@command -v terraform >/dev/null 2>&1 && echo "✓ Terraform installed" || echo "✗ Terraform not found"
	@command -v az >/dev/null 2>&1 && echo "✓ Azure CLI installed" || echo "✗ Azure CLI not found"
	@command -v kubectl >/dev/null 2>&1 && echo "✓ kubectl installed" || echo "✗ kubectl not found"
	@echo "Checking Azure login..."
	@az account show > /dev/null 2>&1 && echo "✓ Azure authenticated" || echo "✗ Not authenticated with Azure"

# Logging targets
logs-app-gateway:
	@terraform output -raw log_analytics_workspace_id | xargs -I {} az monitor log-analytics query -w {} --analytics-query "AppServiceHTTPLogs"

logs-aks:
	@kubectl logs -n kube-system -l component=kubelet

logs-sql:
	@terraform output -raw storage_account_name | xargs -I {} az storage blob list -c logs --account-name {}

# Update/Upgrade targets
upgrade-tf-version:
	@echo "Current Terraform version:"
	@terraform version
	@echo "Run: brew upgrade terraform (macOS) or apt upgrade terraform (Linux)"

upgrade-aks:
	@read -p "Enter Kubernetes version (e.g., 1.28): " version; \
	terraform apply -var="kubernetes_version=$$version"

