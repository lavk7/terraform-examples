provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
      bucket = "terraform-s3-bucket-lav"
      key = "global/s3/terraform.tfstate"
      region = "ap-southeast-1"
      encrypt  = "true" 
  }
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-s3-bucket-lav"
  versioning {
      enabled = true
  }

  lifecycle {
      prevent_destroy = true
  }
}