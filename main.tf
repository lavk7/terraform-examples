provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
  ami = "ami-05868579"
  instance_type = "t2.micro"

  tags {
      Name = "first"
  }
}

