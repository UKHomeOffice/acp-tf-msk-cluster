variable "name" {
  description = "Name of the MSK cluster"
}

variable "environment" {
  description = "The environment the MSK cluster is running in i.e. dev, prod etc"
}

variable "kafka_version" {
  description = "The Kafka version for the AWS MSK cluster"
  default     = "2.2.1"
}

variable "number_of_broker_nodes" {
  description = "The number of broker nodes running in the MSK cluster"
}

variable "msk_instance_type" {
  description = "The MSK cluster instance type"
}

variable "ebs_volume_size" {
  description = "The MSK cluster EBS volume size for each broker"
}

variable "vpc_id" {
  description = "The MSK cluster's VPC ID"
}

variable "subnet_ids" {
  description = "A list of subnets that the MSK cluster should run in"
  type        = list(string)
}

variable "cidr_blocks" {
  description = "The CIDR blocks that the MSK cluster allows ingress connections from"
  default     = ["0.0.0.0/0"]
}

variable "client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT"
  default     = "TLS_PLAINTEXT"
}

variable "certificateauthority" {
  description = "Should a CA be created with the MSK cluster?"
  default     = false
}

variable "ca_arn" {
  description = "ARN of the AWS managed CA to attach to the MSK cluster"
  default     = []
  type        = list(string)
}

variable "acmpca_iam_user_name" {
  description = "The name of the IAM user assigned to the created AWS Private CA"
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

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "type" {
  description = "The type of the certificate authority"
  default     = ""
}

variable "enhanced_monitoring" {
  description = "The desired enhanced MSK CloudWatch monitoring level"
  default     = "DEFAULT"
}

variable "prometheus_jmx_exporter_enabled" {
  description = "Enable Prometheus open monitoring for the JMX exporter"
  default     = false
}

variable "prometheus_node_exporter_enabled" {
  description = "Enable Prometheus open monitoring for the node exporter"
  default     = false
}

variable "encryption_at_rest_kms_key_arn" {
  description = "Use to set custom KMS key to encrypt data written to EBS volume"
  default     = null
}

variable "key_rotation" {
  description = "Enable email notifications for old IAM keys."
  default     = "true"
}

variable "email_addresses" {
  description = "A list of email addresses for key rotation notifications."
  default     = []
}
