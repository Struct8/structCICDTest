resource "aws_launch_template" "ltWordpress" {
  image_id               = "ami-0a2677eea18563e33"
  name                   = "ltWordpress"
  instance_type          = "c7g.medium"
  update_default_version = true
  user_data = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
ECS_CLUSTER="wp-cluster"
NAME="asgWordpress"
REGION="us-west-2"
ACCOUNT="952133486861"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

# --- BEGIN STRUCT8 ECS BOOTSTRAP ---
mkdir -p /etc/ecs
source /etc/struct8_env
echo "ECS_CLUSTER=$ECS_CLUSTER" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config
# --- END STRUCT8 ECS BOOTSTRAP ---

# Tasks use awsvpc: keep them away from the instance metadata service and the instance role.
mkdir -p /etc/ecs
echo "ECS_AWSVPC_BLOCK_IMDS=true" >> /etc/ecs/ecs.config
# Spot: on the two-minute interruption notice, drain the instance so its tasks start elsewhere.
echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=true" >> /etc/ecs/ecs.config

EOFUData
)
  block_device_mappings {
    device_name = "/dev/xvda"
    no_device   = false
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 30
      volume_type           = "gp3"
    }
  }
  enclave_options {
    enabled = false
  }
  hibernation_options {
    configured = false
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.asgWordpress_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  network_interfaces {
    delete_on_termination = true
    device_index          = 0
    ipv4_address_count    = 0
    ipv4_prefix_count     = 0
    ipv6_address_count    = 0
    ipv6_prefix_count     = 0
    network_card_index    = 0
    security_groups       = [aws_security_group.autoscaling_group_asgWordpress_group.id]
  }
  placement {
    tenancy = "default"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      AmazonECSManaged = true
      Name             = "asgWordpress"
      State            = "wordpress-professional"
      Struct8Creator   = "rmay struct"
    }
  }
  tags = {
    Name           = "ltWordpress"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_autoscaling_group" "asgWordpress" {
  name                  = "asgWordpress"
  capacity_rebalance    = true
  desired_capacity      = 1
  enabled_metrics       = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  health_check_type     = "EC2"
  max_instance_lifetime = 0
  max_size              = 6
  metrics_granularity   = "1Minute"
  min_size              = 1
  termination_policies  = ["Default"]
  vpc_zone_identifier   = [aws_subnet.appA.id, aws_subnet.appB.id]
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-best-effort"
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "default"
  }
  instance_maintenance_policy {
    max_healthy_percentage = 100
    min_healthy_percentage = 90
  }
  instance_refresh {
    strategy = "Rolling"
  }
  lifecycle {
    ignore_changes = [desired_capacity]
  }
  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = "prioritized"
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        version            = "1"
        launch_template_id = aws_launch_template.ltWordpress.id
      }
      override {
        instance_type = "c7g.large"
      }
      override {
        instance_type = "c6g.large"
      }
      override {
        instance_type = "c8g.large"
      }
      override {
        instance_type = "m7g.large"
      }
    }
  }
  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = true
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "asgWordpress"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "wordpress-professional"
  }
  tag {
    key                 = "Struct8Creator"
    propagate_at_launch = true
    value               = "rmay struct"
  }
  depends_on = [aws_route_table_association.aws_route_table_association_appA_rtPrivate, aws_route.route_rtPrivate_to_eigw-wp_ipv6, aws_route.route_rtPrivate_to_nat-wp_ipv4, aws_route_table_association.aws_route_table_association_appB_rtPrivate]
}

resource "aws_lambda_permission" "perm_aws_cloudfront_distribution_cdnWordpress_to_analyticsUrl" {
  function_name = data.aws_lambda_function_url.analyticsUrl.function_name
  statement_id  = "perm_aws_cloudfront_distribution_cdnWordpress_to_analyticsUrl"
  principal     = "cloudfront.amazonaws.com"
  action        = "lambda:InvokeFunctionUrl"
  source_arn    = aws_cloudfront_distribution.cdnWordpress.arn
}

resource "aws_lambda_permission" "perm_aws_cloudfront_distribution_cdnWordpress_to_analyticsUrl_invoke" {
  function_name = data.aws_lambda_function_url.analyticsUrl.function_name
  statement_id  = "perm_aws_cloudfront_distribution_cdnWordpress_to_analyticsUrl_invoke"
  principal     = "cloudfront.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_cloudfront_distribution.cdnWordpress.arn
}

resource "aws_appautoscaling_policy" "scalingWordpress-cpu" {
  name               = "scalingWordpress-cpu"
  resource_id        = aws_appautoscaling_target.scalingWordpress.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.scalingWordpress.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scalingWordpress.service_namespace
  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    target_value       = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "scalingWordpress" {
  resource_id        = "service/${aws_ecs_cluster.wp-cluster.name}/${aws_ecs_service.wordpress_service.name}"
  max_capacity       = 12
  min_capacity       = 2
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  suspended_state {
    dynamic_scaling_in_suspended  = false
    dynamic_scaling_out_suspended = false
    scheduled_scaling_suspended   = false
  }
  tags = {
    Name           = "scalingWordpress"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}
