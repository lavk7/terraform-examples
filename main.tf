provider "aws" {
  region = "ap-southeast-1"
}

# resource "aws_instance" "example" {
#   ami = "ami-05868579"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = ["${aws_security_group.instance.id}"]

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello,World" > index.html
#               nohub busyboxy httpd -f -p ${var.server_port} &
#               EOF
#   tags {
#       Name = "second"
#   }
# }

resource "aws_security_group" "instance" {
  name = "test-security-group"
  
  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
      create_before_destroy = true
  }
}


variable "server_port" {
  description = "Just server port"
  default = "8081"
}

# output "public_ip" {
#   value = "${aws_instance.example.public_ip}"
# }


resource "aws_launch_configuration" "example" {
  image_id = "ami-05868579"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example.id}"
    min_size = 2
    max_size = 10
    load_balancers = ["${aws_elb.example.name}"]
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    health_check_type = "ELB"
    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones= ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.elb.id}"]
  listener {
      lb_port = 80
      lb_protocol = "http"
      instance_port = "${var.server_port}"
      instance_protocol = "http"
  }

  health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      interval = 30
      target = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
    name = "example-elb"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


data "aws_availability_zones" "all" {}

# output "public_ip" {
#   value = "${data.aws_availability_zones.all.names}"
# }

output "elb_dns_name" {
    value = "${aws_elb.example.dns_name}"
}