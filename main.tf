/**
 * ## Usage
 *
 * ### MSK Cluster
 * ```hcl
 * module "msk_cluster" {
 *   source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"
 *
 *   name                   = "msktestcluster"
 *   msk_instance_type      = "kafka.m5.large"
 *   kafka_version          = "2.8.1"
 *   environment            = var.environment
 *   number_of_broker_nodes = "3"
 *   subnet_ids             = data.aws_subnet_ids.compute.ids
 *   vpc_id                 = var.vpc_id
 *   ebs_volume_size        = "50"
 *   cidr_blocks            = values(var.compute_cidrs)
 *   # certificateauthority = true (This will fail on merge the first time it's executed, this is expected. Install the CA in the AWS console then restart the merge.)
 *   # or
 *   # ca_arn               = [module.<existing_cert>.ca_certificate_arn]
 * }
 * ```
 *
 * ### MSK Cluster with config
 * ```hcl
 * module "msk_cluster_with_config" {
 *   source = "git::https://github.com/UKHomeOffice/acp-tf-msk-cluster?ref=master"
 *
 *   name                        = "msktestclusterwithconfig"
 *   msk_instance_type           = "kafka.m5.large"
 *   kafka_version               = "2.8.1"
 *   environment                 = var.environment
 *   number_of_broker_nodes      = "3"
 *   subnet_ids                  = data.aws_subnet_ids.compute.ids
 *   vpc_id                      = var.vpc_id
 *   ebs_volume_size             = "50"
 *   cidr_blocks                 = values(var.compute_cidrs)
 *   # certificateauthority      = true (This will fail on merge the first time it's executed, this is expected. Install the CA in the AWS console then restart the merge.)
 *   # or
 *   # ca_arn                    = [module.<existing_cert>.ca_certificate_arn]
 *   config_name                 = "test-msk-config"
 *   config_kafka_versions       = ["2.8.1"]
 *   config_description          = "Test MSK configuration"
 *
 *   config_server_properties = <<PROPERTIES
 *  auto.create.topics.enable = true
 *  delete.topic.enable = true
 *  PROPERTIES
 * }
 * ```
 */


locals {
  aws_acmpca_certificate_authority_arn = coalesce(element(concat(aws_acmpca_certificate_authority.msk_kafka_with_ca.*.arn, [""]), 0), element(concat(aws_acmpca_certificate_authority.msk_kafka_ca_with_config.*.arn, [""]), 0), element(concat(var.ca_arn, [""]), 0))
  msk_cluster_arn                      = coalesce(element(concat(aws_msk_cluster.msk_kafka.*.arn, [""]), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.arn, [""]), 0))
  email_tags                           = { for i, email in var.email_addresses : "email${i}" => email }
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "sg_msk" {
  name        = "${var.name}-kafka-security-group"
  description = "Allow kafka traffic"
  vpc_id      = var.vpc_id

  #Kafka Broker TLS port
  ingress {
    from_port   = 2182
    to_port     = 2182
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  #Zookeeper TLS port
  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
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
  count       = var.encryption_at_rest_kms_key_arn == null ? 1 : 0
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
  count         = var.encryption_at_rest_kms_key_arn == null ? 1 : 0
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.kms[count.index].key_id
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
  
  # Adding lifecycle
  lifecycle {
    ignore_changes = [
      client_authentication["sasl"],
    ]
  }

  client_authentication {
    tls {
      certificate_authority_arns = length(var.ca_arn) != 0 ? var.ca_arn : [aws_acmpca_certificate_authority.msk_kafka_with_ca[count.index].arn]
    }
    sasl {
      iam = var.iam_authentication
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn == null ? aws_kms_key.kms[count.index].arn : var.encryption_at_rest_kms_key_arn

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = "true"
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

  dynamic "logging_info" {
    for_each = var.logging_broker_s3 == null ? [] : [true]
    content {
      broker_logs {
        s3 {
          enabled = var.logging_broker_s3["enabled"]
          bucket  = var.logging_broker_s3["bucket"]
          prefix  = var.logging_broker_s3["prefix"]
        }
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
      certificate_authority_arns = length(var.ca_arn) != 0 ? var.ca_arn : [aws_acmpca_certificate_authority.msk_kafka_ca_with_config[count.index].arn]
    }
    sasl {
      iam = var.iam_authentication
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn == null ? aws_kms_key.kms[count.index].arn : var.encryption_at_rest_kms_key_arn

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = "true"
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

  dynamic "logging_info" {
    for_each = var.logging_broker_s3 == null ? [] : [true]
    content {
      broker_logs {
        s3 {
          enabled = var.logging_broker_s3["enabled"]
          bucket  = var.logging_broker_s3["bucket"]
          prefix  = var.logging_broker_s3["prefix"]
        }
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

  tags = merge(
    var.tags,
    local.email_tags,
    {
      "key_rotation" = var.key_rotation
    },
  )
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

  tags = merge(
    var.tags,
    local.email_tags,
    {
      "key_rotation" = var.key_rotation
    },
  )
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

resource "aws_iam_policy_attachment" "msk_iam_policy_attachment" {
  name       = "${var.name}-policy-attachment"
  users      = [aws_iam_user.msk_iam_user.name]
  policy_arn = aws_iam_policy.msk_iam_policy.arn
}

resource "aws_iam_policy" "msk_iam_authentication" {
  count = var.iam_authentication ? 1 : 0
  name = "${var.name}-iam-auth-policy"
  description = "This policy allow IAM authenticated user to connect to MSK"
  policy = data.aws_iam_policy_document.msk_iam_authentication_document.json
}


resource "aws_iam_policy_attachment" "msk_iam_authentication_policy" {
  count = var.iam_authentication ? 1 : 0
  name = "${var.name}-authentication-policy-attachment"
  users = [ aws_iam_user.msk_iam_user.name ]
  policy_arn = aws_iam_policy.msk_iam_authentication[count.index].arn
}

module "self_serve_access_keys" {
  source = "git::https://github.com/UKHomeOffice/acp-tf-self-serve-access-keys?ref=v0.1.0"

  user_names = concat(aws_iam_user.msk_acmpca_iam_user.*.name, aws_iam_user.msk_iam_user.*.name)
}

resource "aws_appautoscaling_target" "msk_appautoscaling_target" {
  count = var.storage_autoscaling_max_capacity > var.ebs_volume_size ? 1 : 0

  max_capacity       = var.storage_autoscaling_max_capacity
  min_capacity       = 1
  resource_id        = local.msk_cluster_arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  service_namespace  = "kafka"
}

resource "aws_appautoscaling_policy" "msk_appautoscaling_policy" {
  count = var.storage_autoscaling_max_capacity > var.ebs_volume_size ? 1 : 0

  name               = "${var.name}-broker-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = local.msk_cluster_arn
  scalable_dimension = join("", aws_appautoscaling_target.msk_appautoscaling_target.*.scalable_dimension)
  service_namespace  = join("", aws_appautoscaling_target.msk_appautoscaling_target.*.service_namespace)

  target_tracking_scaling_policy_configuration {
    # Can't scale down an msk cluster disk after increasing it.
    disable_scale_in = "true"
    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }

    target_value = var.storage_autoscaling_threshold
  }
}
