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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| CertificateauthorityarnList | ARN of the AWS managed  CA  to attach to the MSK cluster | map | `<map>` | no |
| acmpca\_iam\_user\_name | The name of the iam user assigned to the created AWS Private CA | string | `""` | no |
| certificateauthority | ARN of the AWS managed  CA  to attach to the MSK cluster | string | `"false"` | no |
| cidr\_blocks | MSK cluster cidr blocks | list | `<list>` | no |
| client\_authentication\_type | ARN of the MSK configuration to attach to the MSK cluster | string | `"false"` | no |
| client\_broker | Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT | string | `"TLS_PLAINTEXT"` | no |
| config\_arn | ARN of the MSK configuration to attach to the MSK cluster | string | `""` | no |
| config\_description | The description of the MSK configuration | string | `""` | no |
| config\_kafka\_versions | A list of Kafka versions that the configuration supports | list | `<list>` | no |
| config\_name | Name of the MSK configuration to attach to the MSK cluster | string | `""` | no |
| config\_revision | The revision of the MSK configuration to use | string | `""` | no |
| config\_server\_properties | The properties to set on the MSK cluster. Omitted properties are set to a default value | string | `""` | no |
| ebs\_volume\_size | The msk custer EBS volume size | string | n/a | yes |
| environment | The environment the msk cluster is running in i.e. dev, prod etc | string | n/a | yes |
| iam\_user\_policy\_name | The policy name of attached to the user | string | `""` | no |
| kafka\_version | The kafka version for the AWS MSK cluster | string | `"2.2.1"` | no |
| msk\_instance\_type | The msk custer instance type | string | n/a | yes |
| name | name of the msk cluster | string | n/a | yes |
| number\_of\_broker\_nodes | The number of broker nodes running in the msk cluster | string | n/a | yes |
| policy | The JSON policy for the acmpca | string | `""` | no |
| subnet\_ids | The msk cluster subnet ID | list | n/a | yes |
| tags | A map of tags to add to all resources | map | `<map>` | no |
| type | A map of tags to add to all resources | string | `""` | no |
| vpc\_id | The msk cluster VPC ID | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bootstrap\_brokers | Plaintext connection host:port pairs |
| bootstrap\_brokers\_tls | TLS connection host:port pairs |
| msk\_cluster\_arn | The MSK cluster arn |
| zookeeper\_connect\_string | A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster |

