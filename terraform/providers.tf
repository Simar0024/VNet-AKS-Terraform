terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  # Uncomment and configure for remote state management
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "statersgaksdev"
  #   container_name       = "tfstate"
  #   key                  = "prod/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# Configure Kubernetes provider with local kubeconfig context
# This is optional - you can configure it after applying Terraform
provider "kubernetes" {
  # Uncomment and configure after AKS cluster is created
  # config_path = "~/.kube/config"
  # config_context = "your-aks-context"
}

# Configure Helm provider for installing packages on AKS
# This is optional - you can configure it after applying Terraform
provider "helm" {
  # Uncomment and configure after AKS cluster is created
  # kubernetes {
  #   config_path = "~/.kube/config"
  # }
}
