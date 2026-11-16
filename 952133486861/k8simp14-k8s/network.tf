resource "aws_security_group" "shop_a_web_pod_sg" {
  name        = "k8simp14-eks-shop-a-web-pod-sg"
  vpc_id      = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].vpc_id
  description = "Pods of workload web in namespace shop-a (SecurityGroupPolicy)"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Saida liberada (pod precisa de DNS/API/AWS)"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "shop_b_web_pod_sg" {
  name        = "k8simp14-eks-shop-b-web-pod-sg"
  vpc_id      = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].vpc_id
  description = "Pods of workload web in namespace shop-b (SecurityGroupPolicy)"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Saida liberada (pod precisa de DNS/API/AWS)"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rule_cluster_to_shop_a_web_pod_sg_tcp_80" {
  security_group_id        = aws_security_group.shop_a_web_pod_sg.id
  source_security_group_id = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  description              = "Inbound to web on declared container port (from inside the cluster)"
  from_port                = 80
  protocol                 = "tcp"
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_cluster_to_shop_b_web_pod_sg_tcp_80" {
  security_group_id        = aws_security_group.shop_b_web_pod_sg.id
  source_security_group_id = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  description              = "Inbound to web on declared container port (from inside the cluster)"
  from_port                = 80
  protocol                 = "tcp"
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_a_web_pod_sg_to_cluster_apiserver" {
  security_group_id        = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.shop_a_web_pod_sg.id
  description              = "Kubernetes API from web pods (required by security groups for pods)"
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_a_web_pod_sg_to_cluster_dns_tcp" {
  security_group_id        = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.shop_a_web_pod_sg.id
  description              = "DNS from web pods to CoreDNS (required by security groups for pods)"
  from_port                = 53
  protocol                 = "tcp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_a_web_pod_sg_to_cluster_dns_udp" {
  security_group_id        = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.shop_a_web_pod_sg.id
  description              = "DNS from web pods to CoreDNS (required by security groups for pods)"
  from_port                = 53
  protocol                 = "udp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_a_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080" {
  security_group_id        = data.aws_security_group.instance_k8simp14-backend_group.id
  source_security_group_id = aws_security_group.shop_a_web_pod_sg.id
  description              = "web shop-a to backend"
  from_port                = 8080
  protocol                 = "tcp"
  to_port                  = 8080
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_b_web_pod_sg_to_cluster_apiserver" {
  security_group_id        = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.shop_b_web_pod_sg.id
  description              = "Kubernetes API from web pods (required by security groups for pods)"
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_b_web_pod_sg_to_cluster_dns_tcp" {
  security_group_id        = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.shop_b_web_pod_sg.id
  description              = "DNS from web pods to CoreDNS (required by security groups for pods)"
  from_port                = 53
  protocol                 = "tcp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_b_web_pod_sg_to_cluster_dns_udp" {
  security_group_id        = data.aws_eks_cluster.k8simp14-eks.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.shop_b_web_pod_sg.id
  description              = "DNS from web pods to CoreDNS (required by security groups for pods)"
  from_port                = 53
  protocol                 = "udp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_shop_b_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080" {
  security_group_id        = data.aws_security_group.instance_k8simp14-backend_group.id
  source_security_group_id = aws_security_group.shop_b_web_pod_sg.id
  description              = "web shop-b to backend"
  from_port                = 8080
  protocol                 = "tcp"
  to_port                  = 8080
  type                     = "ingress"
}
