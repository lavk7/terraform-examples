
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
  name = "${var.cluster_name}-security-group"
  
  ingress {
      from_port = "${var.server_port}"
      to_port = "${var.server_port}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_security_group" "ssh" {
    name = "${var.cluster_name}-ssh-security-group"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]     
    }
}


# output "public_ip" {
#   value = "${aws_instance.example.public_ip}"
# }


resource "aws_launch_configuration" "example" {
  image_id = "ami-1c106cf6"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}", "${aws_security_group.ssh.id}"]
  key_name = "${aws_key_pair.general.key_name}"
  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example.id}"
    min_size = 4
    max_size = 10
    load_balancers = ["${aws_elb.example.name}"]
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    health_check_type = "ELB"
    tag {
        key = "Name"
        value = "${var.cluster_name}-terraform-asg-example"
        propagate_at_launch = true
    }
}

resource "aws_elb" "example" {
  name = "${var.cluster_name}-terraform-asg-example"
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
    name = "${var.cluster_name}-example-elb"
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

resource "aws_key_pair" "general" {
    key_name = "${var.cluster_name}-general-keypair"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD0dOzj+gy3QGYz6lEfHME8LfDyALNW/oTxhnTr/E448pVWhhnoeQ0L1wv63JuYJT9M934wUhP8RaYYch9hZXPTZyYFvnb6vQlGvpMkKU+lBjwFBLI8crheZ+p6SrgxCXhk5owfSFCn3lILtb/GkdmJg5RZOl+gnDVQOLN5m+MyiWT8nURWsN47Vp2MWxuGw/KsNhvBwjvi4cdJ2VTqrnO1akNCQnppynXHdh+dptHSD3S5SMDqc0ZxpznWAG19OGuUlINKR3jdTTMyQ2johx37EIGDxGi5kbCwo4EozK7oUyBkod1zbxq3VkgQaam0yrDplH5a6O2AdWA4dfTmeJZZsBkMNsqFoTzKFNDzV1nqbUARsaZunxsfhrgXqDvv6VVlxGobp/DDo/4rfw8nmyTAbIUyU4s5ecEEOBpNfEPk5gjcVozc0mDlhDcoi1a9D8/UWjJDP9Gap2fwDrguDhMl2AU/692eiKnhGUYiwOoFAfGLLfx77FJthL9X9y79Tw9UhVc8w/CAbT1VX5OIarmOqTNKlIRqXlQJfHYvxtSAHZPuAH/wlSrNqD4vIDZzb7OIvj/vKuOnrqotTKa9poYv/Xe6rhjlLWh6t+C97uC9/ji8RiWOCUq+pMhQEugHeFYEOBGQSRptVMIPFUDpm4TZ/xiZZYkWtcX0KKAONykrnQ== lav.nemesis123@gmail.com"
}

data "terraform_remote_state" "db" {
  backend  = "s3"
  config {
      bucket = "terraform-s3-bucket-lav"
      key    = "${var.db_remote_state_key}"
      region = "ap-southeast-1"
  }
}

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
  }
}

