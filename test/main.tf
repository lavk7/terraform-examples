terraform {
  backend "s3" {
      bucket = "terraform-s3-bucket-lav"
      key = "stage/webserver/terraform.tfstate"
      region = "ap-southeast-1"
      encrypt  = "true" 
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
