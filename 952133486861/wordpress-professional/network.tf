resource "aws_vpc" "wordpress-professional" {
  assign_generated_ipv6_cidr_block     = true
  cidr_block                           = "10.0.0.0/16"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  instance_tenancy                     = "default"
  ipv6_cidr_block_network_border_group = "us-west-2"
  tags = {
    Name           = "wordpress-professional"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_vpc_endpoint" "vpce-s3_S3" {
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_id            = aws_vpc.wordpress-professional.id
  policy            = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}],\"Version\":\"2008-10-17\"}"
  route_table_ids   = [aws_route_table.rt-public-wp.id, aws_route_table.rtPrivate.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    Name           = "vpce-s3"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
    DifName        = "vpce-s3_S3"
  }
  timeouts {
    create = "10m"
    delete = "10m"
    update = "10m"
  }
}

resource "aws_vpc_endpoint" "vpceLogs_LOGS" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.logs"
  vpc_id              = aws_vpc.wordpress-professional.id
  ip_address_type     = "dualstack"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_vpceLogs.id]
  subnet_ids          = [aws_subnet.appA.id, aws_subnet.appB.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "vpceLogs"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
    DifName        = "vpceLogs_LOGS"
  }
  timeouts {
    create = "10m"
    delete = "10m"
    update = "10m"
  }
}

resource "aws_vpc_endpoint" "vpceSecrets_SECRETSMANAGER" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_id              = aws_vpc.wordpress-professional.id
  ip_address_type     = "dualstack"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_vpceSecrets.id]
  subnet_ids          = [aws_subnet.appA.id, aws_subnet.appB.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "vpceSecrets"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
    DifName        = "vpceSecrets_SECRETSMANAGER"
  }
  timeouts {
    create = "10m"
    delete = "10m"
    update = "10m"
  }
}

resource "aws_subnet" "appA" {
  vpc_id                              = aws_vpc.wordpress-professional.id
  assign_ipv6_address_on_creation     = true
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.0.11.0/24"
  ipv6_cidr_block                     = "2600:1f14:1e19:a10b::/64"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "appA"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "appB" {
  vpc_id                              = aws_vpc.wordpress-professional.id
  assign_ipv6_address_on_creation     = true
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.0.12.0/24"
  ipv6_cidr_block                     = "2600:1f14:1e19:a10c::/64"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "appB"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "dataA" {
  vpc_id                              = aws_vpc.wordpress-professional.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.0.21.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "dataA"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "dataB" {
  vpc_id                              = aws_vpc.wordpress-professional.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.0.22.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "dataB"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "pubA" {
  vpc_id                              = aws_vpc.wordpress-professional.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.0.1.0/24"
  ipv6_cidr_block                     = "2600:1f14:1e19:a101::/64"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "pubA"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "pubB" {
  vpc_id                              = aws_vpc.wordpress-professional.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.0.2.0/24"
  ipv6_cidr_block                     = "2600:1f14:1e19:a102::/64"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "pubB"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw-wp" {
  vpc_id = aws_vpc.wordpress-professional.id
  tags = {
    Name           = "igw-wp"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_egress_only_internet_gateway" "eigw-wp" {
  vpc_id = aws_vpc.wordpress-professional.id
  tags = {
    Name           = "eigw-wp"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "nat-wp" {
  vpc_id            = aws_vpc.wordpress-professional.id
  availability_mode = "regional"
  connectivity_type = "public"
  tags = {
    Name           = "nat-wp"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.igw-wp]
}

resource "aws_route" "route_rt-public-wp_to_igw-wp_ipv4" {
  gateway_id             = aws_internet_gateway.igw-wp.id
  route_table_id         = aws_route_table.rt-public-wp.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_rt-public-wp_to_igw-wp_ipv6" {
  gateway_id                  = aws_internet_gateway.igw-wp.id
  route_table_id              = aws_route_table.rt-public-wp.id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_route" "route_rtPrivate_to_eigw-wp_ipv6" {
  egress_only_gateway_id      = aws_egress_only_internet_gateway.eigw-wp.id
  route_table_id              = aws_route_table.rtPrivate.id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_route" "route_rtPrivate_to_nat-wp_ipv4" {
  nat_gateway_id         = aws_nat_gateway.nat-wp.id
  route_table_id         = aws_route_table.rtPrivate.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route53_record" "Route53_Record_certAlb_origin_wp_cloudman_pro" {
  for_each = {
    for dvo in aws_acm_certificate.certAlb.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "origin.wp.cloudman.pro"
  }
  name            = each.value.resource_record_name
  zone_id         = data.aws_route53_zone.wpZone.zone_id
  allow_overwrite = true
  records         = [each.value.resource_record_value]
  ttl             = 300
  type            = each.value.resource_record_type
}

resource "aws_route53_record" "Route53_Record_certWordpress_wp_cloudman_pro" {
  for_each = {
    for dvo in aws_acm_certificate.certWordpress.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "wp.cloudman.pro"
  }
  name            = each.value.resource_record_name
  zone_id         = data.aws_route53_zone.wpZone.zone_id
  allow_overwrite = true
  records         = [each.value.resource_record_value]
  ttl             = 300
  type            = each.value.resource_record_type
}

resource "aws_route53_record" "alias_a_aws_cloudfront_distribution_cdnWordpress_wp_cloudman_pro" {
  name    = "wp.cloudman.pro"
  zone_id = data.aws_route53_zone.wpZone.zone_id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdnWordpress.domain_name
    zone_id                = aws_cloudfront_distribution.cdnWordpress.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_aaaa_aws_cloudfront_distribution_cdnWordpress_wp_cloudman_pro" {
  name    = "wp.cloudman.pro"
  zone_id = data.aws_route53_zone.wpZone.zone_id
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.cdnWordpress.domain_name
    zone_id                = aws_cloudfront_distribution.cdnWordpress.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_aaaa_aws_lb_alb-wp_origin_wp_cloudman_pro" {
  name    = "origin.wp.cloudman.pro"
  zone_id = data.aws_route53_zone.wpZone.zone_id
  type    = "AAAA"
  alias {
    name                   = aws_lb.alb-wp.dns_name
    zone_id                = aws_lb.alb-wp.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dkim_wpMail_wp_cloudman_pro" {
  for_each = {
    for i in range(3) : tostring(i) => {
      name  = "${aws_sesv2_email_identity.wpMail.dkim_signing_attributes[0].tokens[i]}._domainkey.wp.cloudman.pro."
      value = "${aws_sesv2_email_identity.wpMail.dkim_signing_attributes[0].tokens[i]}.dkim.amazonses.com."
    }
  }
  name            = each.value.name
  zone_id         = data.aws_route53_zone.wpZone.zone_id
  allow_overwrite = true
  records         = [each.value.value]
  ttl             = 300
  type            = "CNAME"
}

resource "aws_route_table" "rt-public-wp" {
  vpc_id = aws_vpc.wordpress-professional.id
  tags = {
    Name           = "rt-public-wp"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rtPrivate" {
  vpc_id = aws_vpc.wordpress-professional.id
  tags = {
    Name           = "rtPrivate"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_appA_rtPrivate" {
  route_table_id = aws_route_table.rtPrivate.id
  subnet_id      = aws_subnet.appA.id
}

resource "aws_route_table_association" "aws_route_table_association_appB_rtPrivate" {
  route_table_id = aws_route_table.rtPrivate.id
  subnet_id      = aws_subnet.appB.id
}

resource "aws_route_table_association" "aws_route_table_association_pubA_rt_public_wp" {
  route_table_id = aws_route_table.rt-public-wp.id
  subnet_id      = aws_subnet.pubA.id
}

resource "aws_route_table_association" "aws_route_table_association_pubB_rt_public_wp" {
  route_table_id = aws_route_table.rt-public-wp.id
  subnet_id      = aws_subnet.pubB.id
}

resource "aws_security_group" "alb-cloudfront-wp" {
  name                   = "alb-cloudfront-wp"
  vpc_id                 = aws_vpc.wordpress-professional.id
  description            = "HTTPS from CloudFront origin-facing servers to the WordPress load balancer"
  revoke_rules_on_delete = false
  tags = {
    Name           = "alb-cloudfront-wp"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "autoscaling_group_asgWordpress_group" {
  name                   = "autoscaling_group_asgWordpress_group"
  vpc_id                 = aws_vpc.wordpress-professional.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "autoscaling_group_asgWordpress_group"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "ecs_task_definition_wordpress_group" {
  name                   = "ecs_task_definition_wordpress_group"
  vpc_id                 = aws_vpc.wordpress-professional.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "ecs_task_definition_wordpress_group"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "efs_file_system_wpContent_group" {
  name                   = "efs_file_system_wpContent_group"
  vpc_id                 = aws_vpc.wordpress-professional.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "efs_file_system_wpContent_group"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "elasticache_replication_group_wpRedis_group" {
  name                   = "elasticache_replication_group_wpRedis_group"
  vpc_id                 = aws_vpc.wordpress-professional.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "elasticache_replication_group_wpRedis_group"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "lb_alb-wp_group" {
  name                   = "lb_alb-wp_group"
  vpc_id                 = aws_vpc.wordpress-professional.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "lb_alb-wp_group"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "rds_cluster_wp-aurora_group" {
  name                   = "rds_cluster_wp-aurora_group"
  vpc_id                 = aws_vpc.wordpress-professional.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "rds_cluster_wp-aurora_group"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "sg_vpce_vpceLogs" {
  name        = "vpce-sg-vpcelogs"
  vpc_id      = aws_vpc.wordpress-professional.id
  description = "Auto-generated SG for vpceLogs"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "vpceLogs"
    DifName        = "sg_vpce_vpceLogs"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "sg_vpce_vpceSecrets" {
  name        = "vpce-sg-vpcesecrets"
  vpc_id      = aws_vpc.wordpress-professional.id
  description = "Auto-generated SG for vpceSecrets"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "vpceSecrets"
    DifName        = "sg_vpce_vpceSecrets"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_alb_cloudfront_wp_cloudfront_ipv6_tcp_443" {
  security_group_id = aws_security_group.alb-cloudfront-wp.id
  description       = "HTTPS from CloudFront over IPv6"
  from_port         = 443
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront_origin_facing_ipv6.id]
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_alb_cloudfront_wp_egress_all_protocols" {
  security_group_id = aws_security_group.alb-cloudfront-wp.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_asgWordpress_group_egress_all_protocols" {
  security_group_id = aws_security_group.autoscaling_group_asgWordpress_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_ecs_task_definition_wordpress_group_egress_all_protocols" {
  security_group_id = aws_security_group.ecs_task_definition_wordpress_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_ecs_task_definition_wordpress_group_to_efs_file_system_wpContent_group_tcp_2049" {
  security_group_id        = aws_security_group.efs_file_system_wpContent_group.id
  source_security_group_id = aws_security_group.ecs_task_definition_wordpress_group.id
  description              = "NFS from the WordPress tasks to EFS"
  from_port                = 2049
  protocol                 = "tcp"
  to_port                  = 2049
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_ecs_task_definition_wordpress_group_to_elasticache_replication_group_wpRedis_group_tcp_6379" {
  security_group_id        = aws_security_group.elasticache_replication_group_wpRedis_group.id
  source_security_group_id = aws_security_group.ecs_task_definition_wordpress_group.id
  description              = "Redis from the WordPress tasks"
  from_port                = 6379
  protocol                 = "tcp"
  to_port                  = 6379
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_ecs_task_definition_wordpress_group_to_rds_cluster_wp_aurora_group_tcp_3306" {
  security_group_id        = aws_security_group.rds_cluster_wp-aurora_group.id
  source_security_group_id = aws_security_group.ecs_task_definition_wordpress_group.id
  description              = "MySQL from the WordPress tasks"
  from_port                = 3306
  protocol                 = "tcp"
  to_port                  = 3306
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_efs_file_system_wpContent_group_egress_all_protocols" {
  security_group_id = aws_security_group.efs_file_system_wpContent_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_elasticache_replication_group_wpRedis_group_egress_all_protocols" {
  security_group_id = aws_security_group.elasticache_replication_group_wpRedis_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_wp_group_egress_all_protocols" {
  security_group_id = aws_security_group.lb_alb-wp_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_wp_group_to_ecs_task_definition_wordpress_group_tcp_443" {
  security_group_id        = aws_security_group.ecs_task_definition_wordpress_group.id
  source_security_group_id = aws_security_group.lb_alb-wp_group.id
  description              = "HTTPS from the load balancer to the WordPress tasks"
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_rds_cluster_wp_aurora_group_egress_all_protocols" {
  security_group_id = aws_security_group.rds_cluster_wp-aurora_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_vpceLogs_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_vpceLogs.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_vpceLogs_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_vpceLogs.id
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_sg_vpce_vpceSecrets_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_vpceSecrets.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_vpceSecrets_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_vpceSecrets.id
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}

resource "aws_lb" "alb-wp" {
  name                             = "albWordpress"
  drop_invalid_header_fields       = true
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60
  ip_address_type                  = "dualstack-without-public-ipv4"
  load_balancer_type               = "application"
  preserve_host_header             = true
  security_groups                  = [aws_security_group.alb-cloudfront-wp.id, aws_security_group.lb_alb-wp_group.id]
  subnets                          = [aws_subnet.pubA.id, aws_subnet.pubB.id]
  access_logs {
    bucket  = aws_s3_bucket.albLogs.id
    enabled = true
  }
  tags = {
    Name           = "alb-wp"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_s3_bucket_policy.aws_s3_bucket_policy_albLogs_st_wordpress-professional]
}

resource "aws_lb_listener" "listenerHttps" {
  certificate_arn                      = aws_acm_certificate_validation.Validation_certAlb.certificate_arn
  load_balancer_arn                    = aws_lb.alb-wp.arn
  port                                 = 443
  protocol                             = "HTTPS"
  routing_http_response_server_enabled = true
  ssl_policy                           = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  default_action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
  mutual_authentication {
    mode = "off"
  }
  tags = {
    Name           = "listenerHttps"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_listener_rule" "ruleFromCloudFront" {
  action {
    order = 1
    type  = "forward"
    forward {
      stickiness {
        duration = 0
        enabled  = false
      }
      target_group {
        arn    = aws_lb_target_group.tgWordpress.arn
        weight = 1
      }
    }
  }
  condition {
    http_header {
      http_header_name = "X-Origin-Verify"
      values           = [random_id.originVerify.hex]
    }
  }
  listener_arn = aws_lb_listener.listenerHttps.arn
  priority     = 1
  tags = {
    Name           = "ruleFromCloudFront"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group" "tgWordpress" {
  name                               = "tgWordpress"
  vpc_id                             = aws_vpc.wordpress-professional.id
  deregistration_delay               = "300"
  ip_address_type                    = "ipv4"
  lambda_multi_value_headers_enabled = false
  load_balancing_algorithm_type      = "round_robin"
  load_balancing_anomaly_mitigation  = "off"
  load_balancing_cross_zone_enabled  = "use_load_balancer_configuration"
  port                               = 443
  protocol                           = "HTTPS"
  protocol_version                   = "HTTP1"
  target_type                        = "ip"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200-399"
    path                = "/wp-includes/images/blank.gif"
    port                = "443"
    protocol            = "HTTPS"
    timeout             = 10
    unhealthy_threshold = 5
  }
  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
  tags = {
    Name           = "tgWordpress"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }
    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }
}

resource "aws_cloudfront_distribution" "cdnWordpress" {
  web_acl_id          = aws_wafv2_web_acl.wpWaf.arn
  aliases             = ["wp.cloudman.pro"]
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  wait_for_deployment = true
  default_cache_behavior {
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.cspReportOnly.id
    target_origin_id           = "originAlb"
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    realtime_log_config_arn    = data.aws_cloudfront_realtime_log_config.cdnLogConfig.arn
    viewer_protocol_policy     = "redirect-to-https"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.traceStart.arn
    }
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.cspReportOnly.id
    target_origin_id           = "originAlb"
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = false
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    path_pattern               = "/wp-admin/*"
    smooth_streaming           = false
    viewer_protocol_policy     = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.cspReportOnly.id
    target_origin_id           = "originMedia"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = false
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    path_pattern               = "/wp-content/media/*"
    smooth_streaming           = false
    viewer_protocol_policy     = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.cspReportOnly.id
    target_origin_id           = "originAlb"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = false
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    path_pattern               = "/wp-content/*"
    smooth_streaming           = false
    viewer_protocol_policy     = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.cspReportOnly.id
    target_origin_id           = "analytics"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = false
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    path_pattern               = "/analytics*"
    smooth_streaming           = false
    viewer_protocol_policy     = "redirect-to-https"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.traceStartLambda.arn
    }
    grpc_config {
      enabled = false
    }
  }
  origin {
    domain_name                 = "origin.wp.cloudman.pro"
    origin_id                   = "originAlb"
    response_completion_timeout = 0
    custom_header {
      name  = "X-Origin-Verify"
      value = random_id.originVerify.hex
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      ip_address_type        = "ipv6"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  origin {
    domain_name                 = trimsuffix(trimprefix(data.aws_lambda_function_url.analyticsUrl.function_url, "https://"), "/")
    origin_access_control_id    = aws_cloudfront_origin_access_control.OAC.id
    origin_id                   = "analytics"
    response_completion_timeout = 0
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  origin {
    domain_name                 = aws_s3_bucket.wpMedia.bucket_regional_domain_name
    origin_access_control_id    = aws_cloudfront_origin_access_control.oac_wpmedia.id
    origin_id                   = "originMedia"
    response_completion_timeout = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "cdnWordpress"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.Validation_certWordpress.certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_function" "traceStart" {
  name = "traceStart"
  code = <<-EOF
// Starts the trace of each request at the edge. It writes the trace id that the
// load balancer keeps and WordPress uses (X-Amzn-Trace-Id, Root field), the
// time the request reached CloudFront in milliseconds (X-Request-Start), and the
// id of this distribution (X-Cdn-Distribution-Id), which names the CloudFront
// node of the trace map. Values sent by the visitor are replaced, so a visitor
// cannot choose the trace id or the node's name.
// Date returns the time this function started, the same value for the whole run.
function handler(event) {
  var request = event.request;
  var now = Date.now();
  var id = '';
  for (var i = 0; i < 24; i++) {
    id += Math.floor(Math.random() * 16).toString(16);
  }
  request.headers['x-amzn-trace-id'] = { value: 'Root=1-' + Math.floor(now / 1000).toString(16) + '-' + id };
  request.headers['x-request-start'] = { value: 't=' + now };
  request.headers['x-cdn-distribution-id'] = { value: event.context.distributionId };
  return request;
}
EOF
  comment = "Starts the trace at the edge: writes X-Amzn-Trace-Id (Root), X-Request-Start and X-Cdn-Distribution-Id."
  publish = true
  runtime = "cloudfront-js-2.0"
  tags = {
    Name           = "traceStart"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudfront_function" "traceStartLambda" {
  name = "traceStartLambda"
  code = <<-EOF
// Starts the trace of each request at the edge, for an origin that is a Lambda
// function URL. X-Amzn-Trace-Id carries a new Root, a Parent and Sampled=1: the
// function joins this trace under the Parent, and its code writes the segment of
// that id, which stands for this distribution. X-Request-Start is the time the
// request reached CloudFront in milliseconds, and X-Cdn-Distribution-Id names the
// distribution. Values sent by the visitor are replaced.
// Date returns the time this function started, the same value for the whole run.
function hex(length) {
  var text = '';
  for (var i = 0; i < length; i++) {
    text += Math.floor(Math.random() * 16).toString(16);
  }
  return text;
}

function handler(event) {
  var request = event.request;
  var now = Date.now();
  var root = '1-' + Math.floor(now / 1000).toString(16) + '-' + hex(24);
  request.headers['x-amzn-trace-id'] = { value: 'Root=' + root + ';Parent=' + hex(16) + ';Sampled=1' };
  request.headers['x-request-start'] = { value: 't=' + now };
  request.headers['x-cdn-distribution-id'] = { value: event.context.distributionId };
  return request;
}
EOF
  comment = "Starts the trace at the edge for a Lambda origin: X-Amzn-Trace-Id with Root, Parent and Sampled."
  publish = true
  runtime = "cloudfront-js-2.0"
  tags = {
    Name           = "traceStartLambda"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudfront_origin_access_control" "OAC" {
  name                              = "OAC"
  description                       = "Managed by Terraform"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "oac_wpmedia" {
  name                              = "oac-wpmedia"
  description                       = "OAC for wpmedia"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_wafv2_web_acl" "wpWaf" {
  name   = "wpWaf"
  region = "us-east-1"
  rule_json = <<EOF
[
  {
    "Name": "ip-reputation",
    "Priority": 0,
    "Statement": {
      "ManagedRuleGroupStatement": { "VendorName": "AWS", "Name": "AWSManagedRulesAmazonIpReputationList" }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": { "SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "ip-reputation" }
  },
  {
    "Name": "known-bad-inputs",
    "Priority": 1,
    "Statement": {
      "ManagedRuleGroupStatement": { "VendorName": "AWS", "Name": "AWSManagedRulesKnownBadInputsRuleSet" }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": { "SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "known-bad-inputs" }
  },
  {
    "Name": "wordpress",
    "Priority": 2,
    "Statement": {
      "ManagedRuleGroupStatement": { "VendorName": "AWS", "Name": "AWSManagedRulesWordPressRuleSet" }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": { "SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "wordpress" }
  },
  {
    "Name": "php",
    "Priority": 3,
    "Statement": {
      "ManagedRuleGroupStatement": { "VendorName": "AWS", "Name": "AWSManagedRulesPHPRuleSet" }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": { "SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "php" }
  },
  {
    "Name": "login-rate-limit",
    "Priority": 10,
    "Statement": {
      "RateBasedStatement": {
        "Limit": 100,
        "AggregateKeyType": "IP",
        "ScopeDownStatement": {
          "RegexMatchStatement": {
            "RegexString": "^/wp-login\\.php",
            "FieldToMatch": { "UriPath": {} },
            "TextTransformations": [{ "Priority": 0, "Type": "LOWERCASE" }]
          }
        }
      }
    },
    "Action": { "Block": {} },
    "VisibilityConfig": { "SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "login-rate-limit" }
  },
  {
    "Name": "rate-limit",
    "Priority": 11,
    "Statement": {
      "RateBasedStatement": { "Limit": 2000, "AggregateKeyType": "IP" }
    },
    "Action": { "Block": {} },
    "VisibilityConfig": { "SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "rate-limit" }
  }
]
  EOF
  scope = "CLOUDFRONT"
  default_action {
    allow {
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name           = "wpWaf"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
  visibility_config {
    metric_name                = "wpWaf"
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }
}
