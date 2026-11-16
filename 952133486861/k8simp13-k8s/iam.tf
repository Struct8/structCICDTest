data "aws_iam_policy_document" "doc_perm_role_irsa_shop_a_web" {
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [data.aws_sqs_queue.k8simp13-orders.arn]
  }
}

data "aws_iam_policy_document" "doc_perm_role_irsa_shop_b_web" {
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [data.aws_sqs_queue.k8simp13-orders.arn]
  }
  statement {
    sid       = "AllowSecretRead"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [data.aws_secretsmanager_secret.k8simp13-db.arn]
  }
  statement {
    sid       = "AllowSecretReadApi"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [data.aws_secretsmanager_secret.k8simp13-api.arn]
  }
}

data "aws_iam_policy_document" "doc_trust_role_irsa_shop_a_web" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [data.aws_iam_openid_connect_provider.eks_oidc_k8simp13-eks.arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:shop-a:web-sa"]
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_oidc_k8simp13-eks.url, "https://", "")}:sub"
    }
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_oidc_k8simp13-eks.url, "https://", "")}:aud"
    }
  }
}

data "aws_iam_policy_document" "doc_trust_role_irsa_shop_b_web" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [data.aws_iam_openid_connect_provider.eks_oidc_k8simp13-eks.arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:shop-b:web-sa"]
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_oidc_k8simp13-eks.url, "https://", "")}:sub"
    }
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_oidc_k8simp13-eks.url, "https://", "")}:aud"
    }
  }
}

resource "aws_iam_role" "role_irsa_shop_a_web" {
  name               = "irsa-k8simp13-eks-shop-a-web"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_role_irsa_shop_a_web.json
}

resource "aws_iam_role" "role_irsa_shop_b_web" {
  name               = "irsa-k8simp13-eks-shop-b-web"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_role_irsa_shop_b_web.json
}

resource "aws_iam_role_policy" "policy_role_irsa_shop_a_web" {
  name   = "irsa-k8simp13-eks-shop-a-web-access"
  policy = data.aws_iam_policy_document.doc_perm_role_irsa_shop_a_web.json
  role   = aws_iam_role.role_irsa_shop_a_web.id
}

resource "aws_iam_role_policy" "policy_role_irsa_shop_b_web" {
  name   = "irsa-k8simp13-eks-shop-b-web-access"
  policy = data.aws_iam_policy_document.doc_perm_role_irsa_shop_b_web.json
  role   = aws_iam_role.role_irsa_shop_b_web.id
}
