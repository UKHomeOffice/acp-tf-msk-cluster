data "aws_iam_policy_document" "kms_key_policy_document" {
  policy_id = "${var.name}KMSPolicy"

  statement {
    sid    = "IAMPermissions"
    effect = "Allow"

    resources = ["*"]

    actions = [
      "kms:*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "msk_iam_authentication_document" {
  statement {
    sid = "IAMAuthenticationPermission"
    effect = "Allow"
    actions = [ 
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster",
     ]
     resources = [ 
        "${local.msk_cluster_arn}"
      ]
  }
  statement {
    sid = "IAMAuthenticationPermissionTopics"
    effect = "Allow"
    actions = [ 
      "kafka-cluster:*Topic*",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData"
     ]
     resources = [ 
        "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${var.name}/*"
      ]
  }
  statement {
    sid = "IAMAuthenticationPermissionGroup"
    effect = "Allow"
    actions = [ 
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
     ]
     resources = [ 
        "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${var.name}/*"
      ]
  }
}