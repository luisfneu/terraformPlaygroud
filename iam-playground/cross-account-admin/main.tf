data "aws_iam_policy_document" "assume_trust" {
  statement {
    sid     = "AllowSourceAccountToAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = length(var.allowed_principal_arns) > 0 ? var.allowed_principal_arns : [
        "arn:aws:iam::${var.source_account_id}:root"
      ]
    }

    dynamic "condition" {
      for_each = var.require_mfa ? [1] : []
      content {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }
  }
}

resource "aws_iam_role" "admin" {
  provider             = aws.target
  name                 = var.admin_role_name
  description          = "Role de admin cross-account assumida pela conta ${var.source_account_id}"
  assume_role_policy   = data.aws_iam_policy_document.assume_trust.json
  max_session_duration = var.max_session_duration
}

resource "aws_iam_role_policy_attachment" "admin" {
  provider   = aws.target
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "assume_admin" {
  count = var.create_source_group ? 1 : 0

  statement {
    sid       = "AssumeCrossAccountAdmin"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.admin.arn]
  }
}

resource "aws_iam_policy" "assume_admin" {
  count       = var.create_source_group ? 1 : 0
  provider    = aws.source
  name        = "${var.admin_role_name}-assume"
  description = "Permite assumir a role ${var.admin_role_name} na conta destino"
  policy      = data.aws_iam_policy_document.assume_admin[0].json
}

resource "aws_iam_group" "admins" {
  count    = var.create_source_group ? 1 : 0
  provider = aws.source
  name     = var.admin_group_name
  path     = "/"
}

resource "aws_iam_group_policy_attachment" "admins" {
  count      = var.create_source_group ? 1 : 0
  provider   = aws.source
  group      = aws_iam_group.admins[0].name
  policy_arn = aws_iam_policy.assume_admin[0].arn
}
