terraform {
  cloud {
    organization = "Ibeh-Light-org"

    workspaces {
      name = "InnovateMart-eks-ProjectBedrock"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# -----------------------
# VPC Creation
# -----------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"   # You can adjust if needed
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "InnovateMart-eks-ProjectBedrock-VPC"
  }
}