resource "aws_iam_user" "lneu" {
  name          = "lneu"
  path          = "/"
  force_destroy = false
}

data "aws_iam_policy_document" "baseline" {
  statement {
    sid    = "SelfManagePassword"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser",
      "iam:GetAccountPasswordPolicy"
    ]
    resources = [
      aws_iam_user.lneu.arn
    ]
  }

  statement {
    sid    = "SelfManageMFA"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:DeleteVirtualMFADevice"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/aws:username"
      values   = []
    }
  }

  dynamic "statement" {
    for_each = var.enable_readonly_account ? [1] : []
    content {
      sid    = "ReadOnlyWithMFA"
      effect = "Allow"
      actions = [
        "*:Describe*",
        "*:Get*",
        "*:List*"
      ]
      resources = ["*"]
      condition {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }
  }
}

resource "aws_iam_policy" "baseline" {
  name        = "lneu-baseline"
  description = "Self-service (senha/MFA) + leitura com MFA"
  policy      = data.aws_iam_policy_document.baseline.json
}

resource "aws_iam_user_policy_attachment" "baseline_attach" {
  user       = aws_iam_user.lneu.name
  policy_arn = aws_iam_policy.baseline.arn
}

data "aws_iam_policy_document" "s3_rw" {
  count = length(var.s3_write_buckets) > 0 ? 1 : 0

  # Listar o bucket
  statement {
    sid     = "S3ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      for b in var.s3_write_buckets : "arn:aws:s3:::${b}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    sid     = "S3ObjectRW"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      for b in var.s3_write_buckets : "arn:aws:s3:::${b}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "s3_rw" {
  count       = length(var.s3_write_buckets) > 0 ? 1 : 0
  name        = "lneu-s3-rw"
  description = "Acesso RW a buckets S3 específicos (com MFA)"
  policy      = data.aws_iam_policy_document.s3_rw[0].json
}

resource "aws_iam_user_policy_attachment" "s3_rw_attach" {
  count      = length(var.s3_write_buckets) > 0 ? 1 : 0
  user       = aws_iam_user.lneu.name
  policy_arn = aws_iam_policy.s3_rw[0].arn
}