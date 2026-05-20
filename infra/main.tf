terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "6.17.0"
        }
    }

    backend "s3" {
        # bucket passado via: terraform init -backend-config="bucket=garage-terraform-state-<ACCOUNT_ID>"
        key    = "database/terraform.tfstate"
        region = "us-east-1"
    }
}

locals {
    projectName = "garage"
    awsRegion   = "us-east-1"
    services    = ["auth", "billing", "os", "stock"]
}

provider "aws" {
    region = local.awsRegion
}
