resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeTags",
        "ec2:DescribeRouteTables",
        "ec2:GetSecurityGroupsForVpc",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeLoadBalancerAttributes"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
    }
  ],
  "Version": "2012-10-17"
}
  EOF
  tags = {
    Project        = "eks-gw-lab"
    Name           = "AWSLoadBalancerControllerIAMPolicy"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy_eksgw-alb" {
  name        = "AWSLoadBalancerControllerIAMPolicy_eksgw-alb"
  description = "AWS Load Balancer Controller IAM Policy"
  path        = "/"
  policy      = data.http.lbc_iam_policy_eksgw-alb.response_body
}

data "aws_iam_policy_document" "policy_external_dns_eksgw-cluster_st_eksgw-import_doc" {
  statement {
    sid       = "AllowRoute53Changes"
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    sid       = "AllowRoute53Listing"
    effect    = "Allow"
    actions   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy_external_dns_eksgw-cluster_st_eksgw-import" {
  name        = "policy_external_dns_eksgw-cluster_st_eksgw-import"
  description = "External-DNS Route53 permissions for eksgw-cluster"
  policy      = data.aws_iam_policy_document.policy_external_dns_eksgw-cluster_st_eksgw-import_doc.json
  tags = {
    Name           = "policy_external_dns_eksgw-cluster_st_eksgw-import"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "doc_trust_lbc_eksgw-alb" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [data.aws_iam_openid_connect_provider.eks_oidc_eksgw-cluster.arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:kube-system:aws-lbc-eksgw-alb"]
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_oidc_eksgw-cluster.url, "https://", "")}:sub"
    }
  }
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name                  = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRoleWithWebIdentity\",\"Condition\":{\"StringEquals\":{\"oidc.eks.us-west-2.amazonaws.com/id/A127BE1594BA3FBC505E05E910331972:aud\":\"sts.amazonaws.com\",\"oidc.eks.us-west-2.amazonaws.com/id/A127BE1594BA3FBC505E05E910331972:sub\":\"system:serviceaccount:kube-system:aws-load-balancer-controller\"}},\"Effect\":\"Allow\",\"Principal\":{\"Federated\":\"arn:aws:iam::952133486861:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/A127BE1594BA3FBC505E05E910331972\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "eks-gw-lab"
    Name           = "AmazonEKSLoadBalancerControllerRole"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "eksgw-cluster-role" {
  name                  = "eksgw-cluster-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":[\"sts:AssumeRole\",\"sts:TagSession\"],\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "eks-gw-lab"
    Name           = "eksgw-cluster-role"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "eksgw-node-role" {
  name                  = "eksgw-node-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "eks-gw-lab"
    Name           = "eksgw-node-role"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "doc_trust_external_dns_eksgw-cluster" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [data.aws_iam_openid_connect_provider.eks_oidc_eksgw-cluster.arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:kube-system:external-dns"]
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_oidc_eksgw-cluster.url, "https://", "")}:sub"
    }
  }
}

resource "aws_iam_role" "role_external_dns_eksgw-cluster_st_eksgw-import" {
  name               = "role_external_dns_eksgw-cluster_st_eksgw-import"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_external_dns_eksgw-cluster.json
  tags = {
    Name           = "role_external_dns_eksgw-cluster_st_eksgw-import"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_lbc_eksgw-alb" {
  name               = "role_lbc_eksgw-alb"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_lbc_eksgw-alb.json
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_eksgw-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eksgw-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_eksgw-cluster_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksgw-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_eksgw-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eksgw-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_eksgw-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eksgw-node-role.name
}

resource "aws_iam_role_policy_attachment" "attach_ext_dns_eksgw-cluster_st_eksgw-import" {
  policy_arn = aws_iam_policy.policy_external_dns_eksgw-cluster_st_eksgw-import.arn
  role       = aws_iam_role.role_external_dns_eksgw-cluster_st_eksgw-import.name
}

resource "aws_iam_role_policy_attachment" "role_lbc_eksgw-alb_attach" {
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy_eksgw-alb.arn
  role       = aws_iam_role.role_lbc_eksgw-alb.name
}
