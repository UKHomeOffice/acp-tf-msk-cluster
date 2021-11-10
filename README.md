Module usage:

     module "msk_cluster" {
       source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"

       name                   = "msktestclutser"
       msk_instance_type      = "kafka.m5.large"
       kafka_version          = "1.1.1"
       environment            = "${var.environment}"
       number_of_broker_nodes = "3"
       subnet_ids             = ["${data.aws_subnet_ids.suben_id_name.ids}"]
      vpc_id                 = "${var.vpc_id}"
       ebs_volume_size        = "50"
       cidr_blocks            = ["${values(var.compute_cidrs)}"]
     }

     module "msk_cluster_with_config" {
       source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"

       name                   = "msktestclusterwithconfig"
       msk_instance_type      = "kafka.m5.large"
       kafka_version          = "1.1.1"
       environment            = "${var.environment}"
       number_of_broker_nodes = "3"
       subnet_ids             = ["${data.aws_subnet_ids.suben_id_name.ids}"]
       vpc_id                 = "${var.vpc_id}"
       ebs_volume_size        = "50"
       cidr_blocks            = ["${values(var.compute_cidrs)}"]

       config_name           = "testmskconfig"
       config_kafka_versions = ["1.1.1"]
       config_description    = "Test MSK configuration"

       config_server_properties = <<PROPERTIES
     auto.create.topics.enable = true
     delete.topic.enable = true
     PROPERTIES
     }

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_self_serve_access_keys"></a> [self_serve_access_keys](#module_self_serve_access_keys) | git::https://github.com/UKHomeOffice/acp-tf-self-serve-access-keys | v0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acmpca_certificate_authority.msk_kafka_ca_with_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority) | resource |
| [aws_acmpca_certificate_authority.msk_kafka_with_ca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority) | resource |
| [aws_iam_policy.acmpca_policy_with_msk_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.msk_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.msk_acmpca_iam_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.msk_iam_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_user.msk_acmpca_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.msk_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_kms_alias.msk_cluster_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_msk_cluster.msk_kafka](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) | resource |
| [aws_msk_cluster.msk_kafka_with_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) | resource |
| [aws_msk_configuration.msk_kafka_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration) | resource |
| [aws_security_group.sg_msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ca_arn"></a> [ca_arn](#input_ca_arn) | ARN of the AWS managed CA to attach to the MSK cluster | `list(string)` | `[]` | no |
| <a name="input_acmpca_iam_user_name"></a> [acmpca_iam_user_name](#input_acmpca_iam_user_name) | The name of the IAM user assigned to the created AWS Private CA | `string` | `""` | no |
| <a name="input_certificateauthority"></a> [certificateauthority](#input_certificateauthority) | Should a CA be created with the MSK cluster? | `bool` | `false` | no |
| <a name="input_cidr_blocks"></a> [cidr_blocks](#input_cidr_blocks) | The CIDR blocks that the MSK cluster allows ingress connections from | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_egress_cidr_blocks"></a> [egress_cidr_blocks](#input_egress_cidr_blocks) | The CIDR blocks that the MSK cluster allows egress connections to | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_client_broker"></a> [client_broker](#input_client_broker) | Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT | `string` | `"TLS_PLAINTEXT"` | no |
| <a name="input_config_arn"></a> [config_arn](#input_config_arn) | ARN of the MSK configuration to attach to the MSK cluster | `string` | `""` | no |
| <a name="input_config_description"></a> [config_description](#input_config_description) | The description of the MSK configuration | `string` | `""` | no |
| <a name="input_config_kafka_versions"></a> [config_kafka_versions](#input_config_kafka_versions) | A list of Kafka versions that the configuration supports | `list` | `[]` | no |
| <a name="input_config_name"></a> [config_name](#input_config_name) | Name of the MSK configuration to attach to the MSK cluster | `string` | `""` | no |
| <a name="input_config_revision"></a> [config_revision](#input_config_revision) | The revision of the MSK configuration to use | `string` | `""` | no |
| <a name="input_config_server_properties"></a> [config_server_properties](#input_config_server_properties) | The properties to set on the MSK cluster. Omitted properties are set to a default value | `string` | `""` | no |
| <a name="input_ebs_volume_size"></a> [ebs_volume_size](#input_ebs_volume_size) | The MSK cluster EBS volume size for each broker | `any` | n/a | yes |
| <a name="input_email_addresses"></a> [email_addresses](#input_email_addresses) | A list of email addresses for key rotation notifications. | `list` | `[]` | no |
| <a name="input_encryption_at_rest_kms_key_arn"></a> [encryption_at_rest_kms_key_arn](#input_encryption_at_rest_kms_key_arn) | Use to set custom KMS key to encrypt data written to EBS volume | `any` | `null` | no |
| <a name="input_enhanced_monitoring"></a> [enhanced_monitoring](#input_enhanced_monitoring) | The desired enhanced MSK CloudWatch monitoring level | `string` | `"DEFAULT"` | no |
| <a name="input_environment"></a> [environment](#input_environment) | The environment the MSK cluster is running in i.e. dev, prod etc | `any` | n/a | yes |
| <a name="input_kafka_version"></a> [kafka_version](#input_kafka_version) | The Kafka version for the AWS MSK cluster | `string` | `"2.2.1"` | no |
| <a name="input_key_rotation"></a> [key_rotation](#input_key_rotation) | Enable email notifications for old IAM keys. | `string` | `"true"` | no |
| <a name="input_msk_instance_type"></a> [msk_instance_type](#input_msk_instance_type) | The MSK cluster instance type | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | Name of the MSK cluster | `any` | n/a | yes |
| <a name="input_number_of_broker_nodes"></a> [number_of_broker_nodes](#input_number_of_broker_nodes) | The number of broker nodes running in the MSK cluster | `any` | n/a | yes |
| <a name="input_prometheus_jmx_exporter_enabled"></a> [prometheus_jmx_exporter_enabled](#input_prometheus_jmx_exporter_enabled) | Enable Prometheus open monitoring for the JMX exporter | `bool` | `false` | no |
| <a name="input_prometheus_node_exporter_enabled"></a> [prometheus_node_exporter_enabled](#input_prometheus_node_exporter_enabled) | Enable Prometheus open monitoring for the node exporter | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | A list of subnets that the MSK cluster should run in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to add to all resources | `map` | `{}` | no |
| <a name="input_type"></a> [type](#input_type) | The type of the certificate authority | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | The MSK cluster's VPC ID | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_brokers"></a> [bootstrap_brokers](#output_bootstrap_brokers) | Plaintext connection host:port pairs |
| <a name="output_bootstrap_brokers_tls"></a> [bootstrap_brokers_tls](#output_bootstrap_brokers_tls) | TLS connection host:port pairs |
| <a name="output_msk_cluster_arn"></a> [msk_cluster_arn](#output_msk_cluster_arn) | The MSK cluster arn |
| <a name="output_msk_sg_id"></a> [msk_sg_id](#output_msk_sg_id) | The MSK security group ID |
| <a name="output_zookeeper_connect_string"></a> [zookeeper_connect_string](#output_zookeeper_connect_string) | A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster |
