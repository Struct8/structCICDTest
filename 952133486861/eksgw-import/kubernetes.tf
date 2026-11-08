resource "helm_release" "aws_lbc_eksgw-alb" {
  name       = "aws-lbc-eksgw-alb"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  set {
    name  = "clusterName"
    value = aws_eks_cluster.eksgw-cluster.name
  }
  set {
    name  = "serviceAccount.create"
    value = true
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-lbc-eksgw-alb"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.role_lbc_eksgw-alb.arn
  }
  set {
    name  = "region"
    value = data.aws_region.current.region
  }
  set {
    name  = "vpcId"
    value = aws_vpc.eksgw-vpc.id
  }
  depends_on = [aws_iam_role_policy_attachment.role_lbc_eksgw-alb_attach, aws_eks_node_group.eksgw-ng]
}

resource "helm_release" "ext_dns_eksgw-cluster" {
  name       = "external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  set {
    name  = "serviceAccount.create"
    value = true
  }
  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "policy"
    value = "upsert-only"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.role_external_dns_eksgw-cluster_st_eksgw-import.arn
  }
  depends_on = [aws_iam_role_policy_attachment.attach_ext_dns_eksgw-cluster_st_eksgw-import, aws_eks_node_group.eksgw-ng]
}
