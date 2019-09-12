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

#for the msk cluster without custom config
data "aws_iam_policy_document" "acmpca_policy_document_with_msk_only" {
  count = length(var.acmpca_iam_user_name) != 0 && var.config_name == "" && var.config_arn == "" ? 1 : 0

  policy_id = "${var.acmpca_iam_user_name}acmpcaPolicy"

  statement {
    sid    = "IAM-acmpcaPermissions"
    effect = "Allow"

    resources = [
      aws_acmpca_certificate_authority.msk_kafka_with_ca[0].arn,
    ]

    actions = [
      "acm-pca:IssueCertificate",
      "acm-pca:GetCertificate",
    ]
  }
}

#for the msk cluster with custom config
data "aws_iam_policy_document" "acmpca_policy_document_with_msk_config" {
  count = length(var.acmpca_iam_user_name) != 0 && var.config_name != "" || var.config_arn != "" ? 1 : 0

  policy_id = "${var.acmpca_iam_user_name}acmpcaPolicy"

  statement {
    sid    = "IAM-acmpcaPermissions"
    effect = "Allow"

    resources = [
      aws_acmpca_certificate_authority.msk_kafka_ca_with_config[0].arn,
    ]

    actions = [
      "acm-pca:IssueCertificate",
      "acm-pca:GetCertificate",
    ]
  }
}

