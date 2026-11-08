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
