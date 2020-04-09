/**
* Module usage:
*
*      module "msk_cluster" {
*        source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"
*
*        name                   = "msktestclutser"
*        msk_instance_type      = "kafka.m5.large"
*        kafka_version          = "1.1.1"
*        environment            = "${var.environment}"
*        number_of_broker_nodes = "3"
*        subnet_ids             = ["${data.aws_subnet_ids.suben_id_name.ids}"]
*       vpc_id                 = "${var.vpc_id}"
*        ebs_volume_size        = "50"
*        cidr_blocks            = ["${values(var.compute_cidrs)}"]
*      }
*
*      module "msk_cluster_with_config" {
*        source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"
*
*        name                   = "msktestclusterwithconfig"
*        msk_instance_type      = "kafka.m5.large"
*        kafka_version          = "1.1.1"
*        environment            = "${var.environment}"
*        number_of_broker_nodes = "3"
*        subnet_ids             = ["${data.aws_subnet_ids.suben_id_name.ids}"]
*        vpc_id                 = "${var.vpc_id}"
*        ebs_volume_size        = "50"
*        cidr_blocks            = ["${values(var.compute_cidrs)}"]
*
*        config_name           = "testmskconfig"
*        config_kafka_versions = ["1.1.1"]
*        config_description    = "Test MSK configuration"
*
*        config_server_properties = <<PROPERTIES
*      auto.create.topics.enable = true
*      delete.topic.enable = true
*      PROPERTIES
*      }
*
*
 */

locals {
  aws_acmpca_certificate_authority_arn = "${coalesce(element(concat(aws_acmpca_certificate_authority.msk_kafka_with_ca.*.arn, list("")), 0), element(concat(aws_acmpca_certificate_authority.msk_kafka_ca_with_config.*.arn, list("")), 0), element(var.CertificateauthorityarnList, 0))}"
  msk_cluster_arn                      = "${coalesce(element(concat(aws_msk_cluster.msk_kafka.*.arn, list("")), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.arn, list("")), 0))}"
}

data "aws_caller_identity" "current" {}

terraform {
  required_version = ">= 0.12"
}

resource "aws_security_group" "sg_msk" {
  name        = "${var.name}-kafka-security-group"
  description = "Allow kafka traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
  )
}

resource "aws_kms_key" "kms" {
  description = "msk cluster kms key"
  policy      = data.aws_iam_policy_document.kms_key_policy_document.json
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
  )
}


resource "aws_kms_alias" "msk_cluster_kms_alias" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.kms.key_id
}

resource "aws_msk_cluster" "msk_kafka" {
  count = var.config_name == "" && var.config_arn == "" ? 1 : 0

  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    instance_type   = var.msk_instance_type
    ebs_volume_size = var.ebs_volume_size
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.sg_msk.id]
  }

  client_authentication {
    tls {
      certificate_authority_arns = var.CertificateauthorityarnList != "" ? var.CertificateauthorityarnList : [aws_acmpca_certificate_authority.msk_kafka_with_ca[count.index].arn]
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn

    encryption_in_transit {
      client_broker = var.client_broker
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.prometheus_jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.prometheus_node_exporter_enabled
      }
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
  )
}

resource "aws_msk_cluster" "msk_kafka_with_config" {
  count = var.config_name != "" || var.config_arn != "" ? 1 : 0

  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    instance_type   = var.msk_instance_type
    ebs_volume_size = var.ebs_volume_size
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.sg_msk.id]
  }

  client_authentication {
    tls {
      certificate_authority_arns = var.CertificateauthorityarnList != "" ? var.CertificateauthorityarnList : [aws_acmpca_certificate_authority.msk_kafka_ca_with_config[count.index].arn]
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn

    encryption_in_transit {
      client_broker = var.client_broker
    }
  }

  configuration_info {
    arn = coalesce(
      var.config_arn,
      join("", aws_msk_configuration.msk_kafka_config.*.arn)
    )
    revision = coalesce(
      var.config_revision,
      join("", aws_msk_configuration.msk_kafka_config.*.latest_revision)
    )
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.prometheus_jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.prometheus_node_exporter_enabled
      }
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
  )
}

resource "aws_msk_configuration" "msk_kafka_config" {
  count = var.config_name != "" && var.config_arn == "" ? 1 : 0

  kafka_versions = var.config_kafka_versions
  name           = var.config_name
  description    = var.config_description

  server_properties = var.config_server_properties
}

# creates CA for msk Cluster without custom config
resource "aws_acmpca_certificate_authority" "msk_kafka_with_ca" {
  count = var.certificateauthority == "true" && var.config_name == "" && var.config_arn == "" ? 1 : 0

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = var.name

      # add other subjects in this module
    }
  }

  type                            = var.type
  permanent_deletion_time_in_days = 7
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
  )

}

# CA for msk Cluster with custom config

resource "aws_acmpca_certificate_authority" "msk_kafka_ca_with_config" {
  count = var.certificateauthority == "true" && (var.config_name != "" || var.config_arn != "") ? 1 : 0

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = var.name
    }
  }

  type                            = var.type
  permanent_deletion_time_in_days = 7

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
  )

}

resource "aws_iam_user" "msk_acmpca_iam_user" {
  count = var.certificateauthority == "true" ? 1 : 0
  name  = "${var.name}-acmpca-user"
  path  = "/"
}

#policy attachment for CA policy
resource "aws_iam_policy" "acmpca_policy_with_msk_policy" {
  count = var.certificateauthority == "true" ? 1 : 0
  name  = "${var.name}-acmpcaPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAMacmpcaPermissions",
      "Effect": "Allow",
      "Action": [
        "acm-pca:IssueCertificate",
        "acm-pca:GetCertificate"
      ],
      "Resource": "${local.aws_acmpca_certificate_authority_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "msk_acmpca_iam_policy_attachment" {
  count      = var.certificateauthority == "true" ? 1 : 0
  name       = "${var.name}-acmpcaPolicy-attachment"
  users      = [aws_iam_user.msk_acmpca_iam_user[count.index].name]
  policy_arn = aws_iam_policy.acmpca_policy_with_msk_policy[count.index].arn
}

resource "aws_iam_user" "msk_iam_user" {
  name = "${var.name}-user"
  path = "/"
}

resource "aws_iam_policy" "msk_iam_policy" {
  name = "${var.name}-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAMPermissions",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics"
      ],
      "Resource": "${local.msk_cluster_arn}"
    }
  ]
}
EOF
}

resource aws_iam_policy_attachment "msk_iam_policy_attachment" {
  name       = "${var.name}-policy-attachment"
  users      = [aws_iam_user.msk_iam_user.name]
  policy_arn = aws_iam_policy.msk_iam_policy.arn
}
