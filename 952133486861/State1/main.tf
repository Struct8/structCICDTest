terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/State1/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "wp-ssm-profile" {
  name                              = "wp-ssm-profile"
  path                              = "/"
  role                              = "${aws_iam_role.ssm_role.name}"
}

resource "aws_iam_role" "ssm_role" {
  name                              = "wp-ssm-role"
  assume_role_policy                = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies             = false
  managed_policy_arns               = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  max_session_duration              = 3600
  path                              = "/"
}

resource "aws_iam_role" "wp_asg_role" {
  name                              = "wp_asg_role"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies             = false
  max_session_duration              = 3600
  path                              = "/"
  tags                              = {
    Name = "wp_asg_role"
    State = "State1"
    Struct8User = "rmay struct"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "main" {
  cidr_block                        = "10.0.0.0/16"
  enable_dns_hostnames              = true
  enable_dns_support                = true
  instance_tenancy                  = "default"
}

resource "aws_subnet" "db_0" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.20.0/24"
  map_public_ip_on_launch           = false
}

resource "aws_subnet" "db_1" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.21.0/24"
  map_public_ip_on_launch           = false
}

resource "aws_subnet" "private_0" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.10.0/24"
  map_public_ip_on_launch           = false
}

resource "aws_subnet" "private_1" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.11.0/24"
  map_public_ip_on_launch           = false
}

resource "aws_subnet" "public_0" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.1.0/24"
  map_public_ip_on_launch           = true
}

resource "aws_subnet" "public_1" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.2.0/24"
  map_public_ip_on_launch           = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id                            = aws_vpc.main.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id                     = aws_eip.eip_nat.id
  subnet_id                         = aws_subnet.public_0.id
  availability_mode                 = "zonal"
}

resource "aws_route" "route_private_to_nat_ipv4" {
  nat_gateway_id                    = aws_nat_gateway.nat.id
  route_table_id                    = aws_route_table.private.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "route_public_to_igw_ipv4" {
  gateway_id                        = aws_internet_gateway.igw.id
  route_table_id                    = aws_route_table.public.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "route_public_to_igw_ipv6" {
  gateway_id                        = aws_internet_gateway.igw.id
  route_table_id                    = aws_route_table.public.id
  destination_ipv6_cidr_block       = "::/0"
}

resource "aws_route_table" "private" {
  vpc_id                            = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id                            = aws_vpc.main.id
}

resource "aws_route_table_association" "aws_route_table_association_private_0_private" {
  route_table_id                    = aws_route_table.private.id
  subnet_id                         = aws_subnet.private_0.id
}

resource "aws_route_table_association" "aws_route_table_association_private_1_private" {
  route_table_id                    = aws_route_table.private.id
  subnet_id                         = aws_subnet.private_1.id
}

resource "aws_route_table_association" "aws_route_table_association_public_0_public" {
  route_table_id                    = aws_route_table.public.id
  subnet_id                         = aws_subnet.public_0.id
}

resource "aws_route_table_association" "aws_route_table_association_public_1_public" {
  route_table_id                    = aws_route_table.public.id
  subnet_id                         = aws_subnet.public_1.id
}

resource "aws_security_group" "wp-alb-sg" {
  name                              = "wp-alb-sg"
  vpc_id                            = aws_vpc.main.id
  description                       = "Permite trafego HTTP externo para o ALB"
  revoke_rules_on_delete            = false
}

resource "aws_security_group" "wp-db-sg" {
  name                              = "wp-db-sg"
  vpc_id                            = aws_vpc.main.id
  description                       = "Permite conexao MySQL vinda apenas das EC2 de aplicacao"
  revoke_rules_on_delete            = false
}

resource "aws_security_group" "wp-efs-sg" {
  name                              = "wp-efs-sg"
  vpc_id                            = aws_vpc.main.id
  description                       = "Permite acesso NFS apenas das EC2 de aplicacao"
  revoke_rules_on_delete            = false
}

resource "aws_security_group" "wp-web-sg" {
  name                              = "wp-web-sg"
  vpc_id                            = aws_vpc.main.id
  description                       = "Permite trafego HTTP apenas vindo do ALB"
  revoke_rules_on_delete            = false
}

resource "aws_security_group_rule" "rule_wp_alb_sg_egress_all_protocols" {
  security_group_id                 = aws_security_group.wp-alb-sg.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_wp_alb_sg_ingress_tcp_80" {
  security_group_id                 = aws_security_group.wp-alb-sg.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 80
  protocol                          = "tcp"
  to_port                           = 80
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_wp_alb_sg_to_wp_web_sg_all_protocols" {
  security_group_id                 = aws_security_group.wp-web-sg.id
  source_security_group_id          = aws_security_group.wp-alb-sg.id
  description                       = "Allow from wp-alb-sg (-1:0-0)"
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_wp_db_sg_egress_all_protocols" {
  security_group_id                 = aws_security_group.wp-db-sg.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_wp_db_sg_ingress_tcp_3306" {
  security_group_id                 = aws_security_group.wp-db-sg.id
  source_security_group_id          = aws_security_group.wp-web-sg.id
  from_port                         = 3306
  protocol                          = "tcp"
  to_port                           = 3306
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_wp_efs_sg_egress_all_protocols" {
  security_group_id                 = aws_security_group.wp-efs-sg.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_wp_efs_sg_ingress_tcp_2049" {
  security_group_id                 = aws_security_group.wp-efs-sg.id
  source_security_group_id          = aws_security_group.wp-web-sg.id
  from_port                         = 2049
  protocol                          = "tcp"
  to_port                           = 2049
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_wp_web_sg_egress_all_protocols" {
  security_group_id                 = aws_security_group.wp-web-sg.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_wp_web_sg_ingress_tcp_80" {
  security_group_id                 = aws_security_group.wp-web-sg.id
  source_security_group_id          = aws_security_group.wp-alb-sg.id
  from_port                         = 80
  protocol                          = "tcp"
  to_port                           = 80
  type                              = "ingress"
}

resource "aws_eip" "eip_nat" {
  domain                            = "vpc"
  tags                              = {
    Name = "eip_nat"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_lb" "alb" {
  name                              = "alb"
  enable_http2                      = true
  idle_timeout                      = 60
  security_groups                   = [aws_security_group.wp-alb-sg.id]
  subnets                           = [aws_subnet.public_0.id, aws_subnet.public_1.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn                 = aws_lb.alb.arn
  port                              = 80
  protocol                          = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    type                            = "fixed-response"
    fixed_response {
      content_type                  = "text/plain"
      message_body                  = "Acesso direto nao permitido. Utilize a distribuicao do CloudFront."
      status_code                   = "403"
    }
  }
}

resource "aws_lb_listener_rule" "cf_only" {
  action {
    type                            = "forward"
    forward {
      target_group {
        arn                         = aws_lb_target_group.tg.arn
      }
    }
  }
  condition {
    http_header {
      http_header_name              = "X-Origin-Verify"
      values                        = [random_password.cf_secret.result]
    }
  }
  listener_arn                      = aws_lb_listener.http.arn
  priority                          = 10
}

resource "aws_lb_target_group" "tg" {
  name                              = "tg"
  vpc_id                            = aws_vpc.main.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  lambda_multi_value_headers_enabled = false
  load_balancing_algorithm_type     = "round_robin"
  port                              = 80
  protocol                          = "HTTP"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "instance"
  health_check {
    enabled                         = true
    healthy_threshold               = 3
    interval                        = 30
    matcher                         = "200-399"
    path                            = "/"
    port                            = "traffic-port"
    protocol                        = "HTTP"
    timeout                         = 5
    unhealthy_threshold             = 3
  }
}

resource "aws_cloudfront_distribution" "wp_distribution" {
  comment                           = "WordPress CDN com Offload S3"
  enabled                           = true
  http_version                      = "http2"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    target_origin_id                = "origin_wp_distribution_org_0"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD"]
    compress                        = false
    default_ttl                     = 0
    max_ttl                         = 0
    min_ttl                         = 0
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      headers                       = ["Authorization", "Host", "Origin"]
      query_string                  = true
      cookies {
        forward                     = "all"
      }
    }
  }
  ordered_cache_behavior {
    target_origin_id                = "origin_wp_distribution_org_1"
    allowed_methods                 = ["GET", "HEAD", "OPTIONS"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = true
    default_ttl                     = 86400
    max_ttl                         = 31536000
    min_ttl                         = 0
    path_pattern                    = "/wp-content/uploads/*"
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      headers                       = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]
      query_string                  = false
      cookies {
        forward                     = "none"
      }
    }
  }
  origin {
    domain_name                     = aws_lb.alb.dns_name
    origin_id                       = "origin_wp_distribution_org_0"
    custom_header {
      name                          = "X-Origin-Verify"
      value                         = random_password.cf_secret.result
    }
    custom_origin_config {
      http_port                     = 80
      https_port                    = 443
      origin_protocol_policy        = "http-only"
      origin_ssl_protocols          = ["TLSv1.2"]
    }
  }
  origin {
    domain_name                     = aws_s3_bucket.wp_media.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_wp_media.id
    origin_id                       = "origin_wp_distribution_org_1"
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate  = true
  }
}

resource "aws_cloudfront_origin_access_control" "oac_wp_media" {
  name                              = "oac-wp_media"
  description                       = "OAC for wp_media"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "wp_media" {
  bucket                            = random_id.bucket_suffix.hex
  force_destroy                     = true
  object_lock_enabled               = false
}

resource "aws_s3_bucket_ownership_controls" "wp_media_controls" {
  bucket                            = aws_s3_bucket.wp_media.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_wp_media_st_State1_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.wp_media.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.wp_distribution.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_wp_media_st_State1" {
  bucket                            = aws_s3_bucket.wp_media.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_wp_media_st_State1_doc.json
}

resource "aws_s3_bucket_public_access_block" "wp_media_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.wp_media.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "wp_media_configuration" {
  bucket                            = aws_s3_bucket.wp_media.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "wp_media_versioning" {
  bucket                            = aws_s3_bucket.wp_media.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_db_instance" "wordpress_db" {
  db_name                           = "wordpress"
  allocated_storage                 = 20
  backup_retention_period           = 0
  engine                            = "mysql"
  engine_version                    = "8.0"
  identifier                        = "wordpress_db"
  instance_class                    = "db.t3.micro"
  password                          = random_password.db_password.result
  skip_final_snapshot               = true
  storage_encrypted                 = true
  storage_type                      = "gp3"
  username                          = "admin"
  vpc_security_group_ids            = [aws_security_group.wp-db-sg.id]
}

resource "aws_efs_file_system" "wp_efs" {
  creation_token                    = "wordpress-files"
  encrypted                         = true
}

resource "aws_efs_mount_target" "mt_wp_efs_private_0" {
  file_system_id                    = aws_efs_file_system.wp_efs.id
  subnet_id                         = aws_subnet.private_0.id
  security_groups                   = [aws_security_group.wp-efs-sg.id]
}

resource "aws_efs_mount_target" "mt_wp_efs_private_1" {
  file_system_id                    = aws_efs_file_system.wp_efs.id
  subnet_id                         = aws_subnet.private_1.id
  security_groups                   = [aws_security_group.wp-efs-sg.id]
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_wp_lt" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "wp_lt" {
  image_id                          = data.aws_ami.AMI_Data_Source_wp_lt.id
  name                              = "wp_lt"
  default_version                   = 1
  instance_type                     = "t3.micro"
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="wp_asg"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---


EOFUData
)
  vpc_security_group_ids            = [aws_security_group.wp-web-sg.id]
  iam_instance_profile {
    name                            = aws_iam_instance_profile.wp-ssm-profile.name
  }
  metadata_options {
    http_endpoint                   = "enabled"
    http_tokens                     = "required"
  }
}

resource "aws_autoscaling_group" "wp_asg" {
  name                              = "wp_asg"
  desired_capacity                  = 2
  force_delete                      = false
  force_delete_warm_pool            = false
  health_check_type                 = "ELB"
  ignore_failed_scaling_activities  = false
  max_size                          = 5
  min_size                          = 2
  target_group_arns                 = [aws_lb_target_group.tg.arn]
  vpc_zone_identifier               = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  wait_for_capacity_timeout         = "10m"
  launch_template {
    version                         = aws_launch_template.wp_lt.latest_version
    id                              = aws_launch_template.wp_lt.id
  }
}

resource "aws_autoscaling_policy" "cpu_scaling" {
  autoscaling_group_name            = aws_autoscaling_group.wp_asg.name
  name                              = "cpu_scaling"
  enabled                           = true
  policy_type                       = "TargetTrackingScaling"
  target_tracking_configuration {
    disable_scale_in                = false
    target_value                    = 70
    predefined_metric_specification {
      predefined_metric_type        = "ASGAverageCPUUtilization"
    }
  }
}




### CATEGORY: MISC ###

resource "random_id" "bucket_suffix" {
  byte_length                       = 8
}

resource "random_password" "cf_secret" {
  length                            = 16
  special                           = true
}

resource "random_password" "db_password" {
  length                            = 16
  special                           = true
}


