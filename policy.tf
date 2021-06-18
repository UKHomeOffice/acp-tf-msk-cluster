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

data "aws_iam_policy_document" "iam_user_access_key_policy_document" {

  policy_id = "${var.name}IAMUserAccessKeyPolicy"

  statement {
    sid    = "ManageOwnIAMKeys"
    effect = "Allow"

    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.name}-user"
    ]
  }
}

data "aws_iam_policy_document" "acmpca_user_access_key_policy_document" {
  count = var.certificateauthority == "true" ? 1 : 0

  policy_id = "${var.name}AcmpcaUserAccessKeyPolicy"

  statement {
    sid    = "ManageOwnIAMKeys"
    effect = "Allow"

    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.name}-acmpca-user"
    ]
  }
}


