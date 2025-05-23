# ==============================================================================
# TERRAFORM CONFIGURATION
# ==============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.40"
    }
  }
}

# ==============================================================================
# AWS PROVIDER CONFIGURATION
# ==============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.datadog_tags
  }
}

# ==============================================================================
# DATADOG PROVIDER CONFIGURATION
# ==============================================================================

provider "datadog" {
  # API credentials - usando variables sensibles
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key

  # API URL - configuración para diferentes sitios de Datadog
  api_url = var.datadog_api_url

  # Validar configuración al startup
  validate = true
}
