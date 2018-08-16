provider "aws" {
  region = "ap-southeast-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  
  cluster_name            = "prod"
  db_remote_state_bucket  = "terraform-s3-bucket-lav"  
  db_remote_state_key     = "stage/data-storage/mysql/terraform.tfstate"
}

terraform {
  backend "s3" {
      bucket = "terraform-s3-bucket-lav"
      key = "prod/webserver/terraform.tfstate"
      region = "ap-southeast-1"
      encrypt  = "true" 
  }
}

