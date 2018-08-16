
variable "server_port" {
  description = "Just server port"
  default = "8081"
}

variable "cluster_name" {
  description = "Enter cluster name"
}

variable "db_remote_state_bucket" {
  description = "Bucket name"
}

variable "db_remote_state_key" {
  description = "db remote key on s3"
}
