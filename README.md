## Compatibility

As of Module version v1.8.0, Plaintext Ports are no longer allowed through the module's security groups for both the broker and zookeeper

This means that from module v1.8.0 onwards the **minimum supported Kafka version is 2.5.1**

Should you require an older version of Kafka than you should use module version v1.7.x. However, the downside is that plaintext ports will be allowed on the older module version

## Usage

### MSK Cluster
```hcl
module "msk_cluster" {
  source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"

  name                   = "msktestcluster"
  msk_instance_type      = "kafka.m5.large"
  kafka_version          = "2.8.1"
  environment            = var.environment
  number_of_broker_nodes = "3"
  subnet_ids             = data.aws_subnet_ids.compute.ids
  vpc_id                 = var.vpc_id
  ebs_volume_size        = "50"
  cidr_blocks            = values(var.compute_cidrs)
  # certificateauthority = true (This will fail on merge the first time it's executed, this is expected. Install the CA in the AWS console then restart the merge.)
  # or
  # ca_arn               = [module.<existing_cert>.ca_certificate_arn]
}
```

### MSK Cluster with config
```hcl
module "msk_cluster_with_config" {
  source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"

  name                        = "msktestclusterwithconfig"
  msk_instance_type           = "kafka.m5.large"
  kafka_version               = "2.8.1"
  environment                 = var.environment
  number_of_broker_nodes      = "3"
  subnet_ids                  = data.aws_subnet_ids.compute.ids
  vpc_id                      = var.vpc_id
  ebs_volume_size             = "50"
  cidr_blocks                 = values(var.compute_cidrs)
  # certificateauthority      = true (This will fail on merge the first time it's executed, this is expected. Install the CA in the AWS console then restart the merge.)
  # or
  # ca_arn                    = [module.<existing_cert>.ca_certificate_arn]
  config_name                 = "test-msk-config"
  config_kafka_versions       = ["2.8.1"]
  config_description          = "Test MSK configuration"

  config_server_properties = <<PROPERTIES
 auto.create.topics.enable = true
 delete.topic.enable = true
 PROPERTIES
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_self_serve_access_keys"></a> [self\_serve\_access\_keys](#module\_self\_serve\_access\_keys) | git::https://github.com/UKHomeOffice/acp-tf-self-serve-access-keys | v0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acmpca_certificate_authority.msk_kafka_ca_with_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority) | resource |
| [aws_acmpca_certificate_authority.msk_kafka_with_ca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority) | resource |
| [aws_appautoscaling_policy.msk_appautoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.msk_appautoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
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
| <a name="input_acmpca_iam_user_name"></a> [acmpca\_iam\_user\_name](#input\_acmpca\_iam\_user\_name) | The name of the IAM user assigned to the created AWS Private CA | `string` | `""` | no |
| <a name="input_ca_arn"></a> [ca\_arn](#input\_ca\_arn) | ARN of the AWS managed CA to attach to the MSK cluster | `list(string)` | `[]` | no |
| <a name="input_certificateauthority"></a> [certificateauthority](#input\_certificateauthority) | Should a CA be created with the MSK cluster? | `bool` | `false` | no |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | The CIDR blocks that the MSK cluster allows ingress connections from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_config_arn"></a> [config\_arn](#input\_config\_arn) | ARN of the MSK configuration to attach to the MSK cluster | `string` | `""` | no |
| <a name="input_config_description"></a> [config\_description](#input\_config\_description) | The description of the MSK configuration | `string` | `""` | no |
| <a name="input_config_kafka_versions"></a> [config\_kafka\_versions](#input\_config\_kafka\_versions) | A list of Kafka versions that the configuration supports | `list(string)` | `[]` | no |
| <a name="input_config_name"></a> [config\_name](#input\_config\_name) | Name of the MSK configuration to attach to the MSK cluster | `string` | `""` | no |
| <a name="input_config_revision"></a> [config\_revision](#input\_config\_revision) | The revision of the MSK configuration to use | `string` | `""` | no |
| <a name="input_config_server_properties"></a> [config\_server\_properties](#input\_config\_server\_properties) | The properties to set on the MSK cluster. Omitted properties are set to a default value | `string` | `""` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | The MSK cluster EBS volume size for each broker | `any` | n/a | yes |
| <a name="input_email_addresses"></a> [email\_addresses](#input\_email\_addresses) | A list of email addresses for key rotation notifications. | `list(string)` | `[]` | no |
| <a name="input_encryption_at_rest_kms_key_arn"></a> [encryption\_at\_rest\_kms\_key\_arn](#input\_encryption\_at\_rest\_kms\_key\_arn) | Use to set custom KMS key to encrypt data written to EBS volume | `any` | `null` | no |
| <a name="input_enhanced_monitoring"></a> [enhanced\_monitoring](#input\_enhanced\_monitoring) | The desired enhanced MSK CloudWatch monitoring level | `string` | `"DEFAULT"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment the MSK cluster is running in i.e. dev, prod etc | `any` | n/a | yes |
| <a name="input_kafka_version"></a> [kafka\_version](#input\_kafka\_version) | The Kafka version for the AWS MSK cluster | `string` | `"2.2.1"` | no |
| <a name="input_key_rotation"></a> [key\_rotation](#input\_key\_rotation) | Enable email notifications for old IAM keys. | `string` | `"true"` | no |
| <a name="input_logging_broker_s3"></a> [logging\_broker\_s3](#input\_logging\_broker\_s3) | Configuration block for Broker Logs settings for s3. | <pre>object({<br>    enabled = bool<br>    bucket  = string<br>    prefix  = string<br>  })</pre> | `null` | no |
| <a name="input_msk_instance_type"></a> [msk\_instance\_type](#input\_msk\_instance\_type) | The MSK cluster instance type | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the MSK cluster | `any` | n/a | yes |
| <a name="input_number_of_broker_nodes"></a> [number\_of\_broker\_nodes](#input\_number\_of\_broker\_nodes) | The number of broker nodes running in the MSK cluster | `any` | n/a | yes |
| <a name="input_prometheus_jmx_exporter_enabled"></a> [prometheus\_jmx\_exporter\_enabled](#input\_prometheus\_jmx\_exporter\_enabled) | Enable Prometheus open monitoring for the JMX exporter | `bool` | `false` | no |
| <a name="input_prometheus_node_exporter_enabled"></a> [prometheus\_node\_exporter\_enabled](#input\_prometheus\_node\_exporter\_enabled) | Enable Prometheus open monitoring for the node exporter | `bool` | `false` | no |
| <a name="input_storage_autoscaling_max_capacity"></a> [storage\_autoscaling\_max\_capacity](#input\_storage\_autoscaling\_max\_capacity) | The MSK cluster EBS maximum volume size for each broker. Value between 1 and 16384. | `number` | `1` | no |
| <a name="input_storage_autoscaling_threshold"></a> [storage\_autoscaling\_threshold](#input\_storage\_autoscaling\_threshold) | The percentage threshold that needs to be exceeded to trigger a scale up. Value between 10 and 80. | `number` | `65` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnets that the MSK cluster should run in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of the certificate authority | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The MSK cluster's VPC ID | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_brokers"></a> [bootstrap\_brokers](#output\_bootstrap\_brokers) | Plaintext connection host:port pairs |
| <a name="output_bootstrap_brokers_tls"></a> [bootstrap\_brokers\_tls](#output\_bootstrap\_brokers\_tls) | TLS connection host:port pairs |
| <a name="output_msk_cluster_arn"></a> [msk\_cluster\_arn](#output\_msk\_cluster\_arn) | The MSK cluster arn |
| <a name="output_msk_sg_id"></a> [msk\_sg\_id](#output\_msk\_sg\_id) | The MSK security group ID |
| <a name="output_zookeeper_connect_string"></a> [zookeeper\_connect\_string](#output\_zookeeper\_connect\_string) | A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster |
