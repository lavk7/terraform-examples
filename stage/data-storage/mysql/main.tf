terraform {
    backend "s3" {
        bucket  = "terraform-s3-bucket-lav"
        key     = "stage/data-storage/mysql/terraform.tfstate"
        region  = "ap-southeast-1"
        encrypt = "true"
    }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_db_instance" "example" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "dev"
  username          = "dev"
  password          = "${var.db_password}"
}
