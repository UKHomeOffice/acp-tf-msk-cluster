variable "name" {
  description = "name of the msk cluster"
}

variable "environment" {
  description = "The environment the msk cluster is running in i.e. dev, prod etc"
}

variable "kafka_version" {
  description = "The kafka version for the AWS MSK cluster"
  default     = "2.2.1"
}

variable "number_of_broker_nodes" {
  description = "The number of broker nodes running in the msk cluster"
}

variable "msk_instance_type" {
  description = "The msk custer instance type"
}

variable "ebs_volume_size" {
  description = "The msk custer EBS volume size"
}

variable "vpc_id" {
  description = "The msk cluster VPC ID "
}

variable "subnet_ids" {
  description = "The msk cluster subnet ID"
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "cidr_blocks" {
  description = "MSK cluster cidr blocks"
  default     = ["0.0.0.0/0"]
}

variable "client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT"
  default     = "TLS_PLAINTEXT"
}
