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
  type        = list(string)
}

variable "cidr_blocks" {
  description = "MSK cluster cidr blocks"
  default     = ["0.0.0.0/0"]
}

variable "client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT"
  default     = "TLS_PLAINTEXT"
}

variable "certificateauthority" {
  description = "ARN of the AWS managed  CA  to attach to the MSK cluster"
  default     = false
}

variable "CertificateauthorityarnList" {
  description = "ARN of the AWS managed  CA  to attach to the MSK cluster"
  default     = {}
}

variable "client_authentication_type" {
  description = "ARN of the MSK configuration to attach to the MSK cluster"
  default     = false
}

variable "acmpca_iam_user_name" {
  description = "The name of the iam user assigned to the created AWS Private CA"
  default     = ""
}

variable "config_name" {
  description = "Name of the MSK configuration to attach to the MSK cluster"
  default     = ""
}

variable "config_kafka_versions" {
  description = "A list of Kafka versions that the configuration supports"
  default     = []
}

variable "config_server_properties" {
  description = "The properties to set on the MSK cluster. Omitted properties are set to a default value"
  default     = ""
}

variable "config_description" {
  description = "The description of the MSK configuration"
  default     = ""
}

variable "config_revision" {
  description = "The revision of the MSK configuration to use"
  default     = ""
}

# to be used if a configuration exists already
variable "config_arn" {
  description = "ARN of the MSK configuration to attach to the MSK cluster"
  default     = ""
}

variable "iam_user_policy_name" {
  description = "The policy name of attached to the user"
  default     = ""
}

variable "policy" {
  description = "The JSON policy for the acmpca"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "type" {
  description = "A map of tags to add to all resources"
  default     = ""
}

variable "enhanced_monitoring" {
  description = "The desired enhanced MSK CloudWatch monitoring level"
  default     = "DEFAULT"
}
