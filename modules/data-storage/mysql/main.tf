

resource "aws_db_instance" "example" {
  name              = "${var.cluster_name}-rdb-18.08.00.000"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "dev"
  username          = "dev"
  password          = "${var.db_password}"
}
