resource "aws_elastic_beanstalk_application" "beanstalk-wordpress" {
  name = "beanstalk-wordpress"
  tags = {
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_elastic_beanstalk_environment" "beanstalk-uptime-kuma" {
  name                   = "beanstalk-uptime-kuma"
  solution_stack_name    = "64bit Amazon Linux 2023 v4.14.0 running Docker"
  application            = aws_elastic_beanstalk_application.beanstalk-wordpress.name
  version_label          = "beanstalk-uptime-kuma-ee0e2fbd65c7589a"
  wait_for_ready_timeout = "20m"
  lifecycle {
    ignore_changes = [version_label]
  }
  setting {
    name      = "ACCOUNT"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "952133486861"
  }
  setting {
    name      = "AWS_DB_INSTANCE_DB_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wordpress"
  }
  setting {
    name      = "AWS_DB_INSTANCE_ENDPOINT_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wp-eb-db.chka200mcp0m.us-east-1.rds.amazonaws.com:3306"
  }
  setting {
    name      = "AWS_DB_INSTANCE_ENGINE_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "mariadb"
  }
  setting {
    name      = "AWS_DB_INSTANCE_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wp-eb-db"
  }
  setting {
    name      = "AWS_DB_INSTANCE_SECRET_ARN_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "arn:aws:secretsmanager:us-east-1:952133486861:secret:rds!db-8c62579e-5edc-459c-91e6-35d1a2b94716-UqmQXc"
  }
  setting {
    name      = "AWS_DB_INSTANCE_USER_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "arn:aws:secretsmanager:us-east-1:952133486861:secret:rds!db-8c62579e-5edc-459c-91e6-35d1a2b94716-UqmQXc:username::"
  }
  setting {
    name      = "AWS_ECR_REPOSITORY_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "kuma-image"
  }
  setting {
    name      = "AWS_ECR_REPOSITORY_URL_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "952133486861.dkr.ecr.us-east-1.amazonaws.com/kuma-image"
  }
  setting {
    name      = "AWS_EFS_ACCESS_POINT_ID_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "fsap-06a864e15a381ab1c"
  }
  setting {
    name      = "AWS_EFS_FILE_SYSTEM_ID_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "fs-01a80eb4655700452"
  }
  setting {
    name      = "AWS_ELASTIC_BEANSTALK_APPLICATION_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "beanstalk-wordpress"
  }
  setting {
    name      = "EnvironmentType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "LoadBalanced"
  }
  setting {
    name      = "InstanceTypes"
    namespace = "aws:ec2:instances"
    value     = "t4g.small"
  }
  setting {
    name      = "LoadBalancerIsShared"
    namespace = "aws:elasticbeanstalk:environment"
    value     = true
  }
  setting {
    name      = "LoadBalancerType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "application"
  }
  setting {
    name      = "MatcherHTTPCode"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    value     = "200-399"
  }
  setting {
    name      = "MaxSize"
    namespace = "aws:autoscaling:asg"
    value     = "1"
  }
  setting {
    name      = "MinSize"
    namespace = "aws:autoscaling:asg"
    value     = "1"
  }
  setting {
    name      = "NAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "beanstalk-uptime-kuma"
  }
  setting {
    name      = "REGION"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "us-east-1"
  }
  setting {
    name      = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "sg-02c69b796c5b447f0"
  }
  setting {
    name      = "SecurityGroups"
    namespace = "aws:elbv2:loadbalancer"
    value     = join(",", aws_lb.wp-shared-alb.security_groups)
  }
  setting {
    name      = "SharedLoadBalancer"
    namespace = "aws:elbv2:loadbalancer"
    value     = aws_lb.wp-shared-alb.arn
  }
  setting {
    name      = "SupportedArchitectures"
    namespace = "aws:ec2:instances"
    value     = "arm64"
  }
  setting {
    name      = "VPCId"
    namespace = "aws:ec2:vpc"
    value     = aws_vpc.vpc-beanstalk-wordpress.id
  }
  setting {
    name      = "Subnets"
    namespace = "aws:ec2:vpc"
    value     = "${aws_subnet.wp-app-a.id},${aws_subnet.wp-app-b.id}"
  }
  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_iam_instance_profile.beanstalk-uptime-kuma_profile.name
  }
  tags = {
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_lb_listener.wp-shared-http]
}

resource "aws_elastic_beanstalk_environment" "beanstalk-wordpress-web" {
  name                   = "beanstalk-wordpress-web"
  solution_stack_name    = "64bit Amazon Linux 2023 v4.14.0 running Docker"
  application            = aws_elastic_beanstalk_application.beanstalk-wordpress.name
  version_label          = "beanstalk-wordpress-web-7011d11521aba401"
  wait_for_ready_timeout = "20m"
  lifecycle {
    ignore_changes = [version_label]
  }
  setting {
    name      = "ACCOUNT"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "952133486861"
  }
  setting {
    name      = "AWS_DB_INSTANCE_DB_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wordpress"
  }
  setting {
    name      = "AWS_DB_INSTANCE_ENDPOINT_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wp-eb-db.chka200mcp0m.us-east-1.rds.amazonaws.com:3306"
  }
  setting {
    name      = "AWS_DB_INSTANCE_ENGINE_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "mariadb"
  }
  setting {
    name      = "AWS_DB_INSTANCE_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wp-eb-db"
  }
  setting {
    name      = "AWS_DB_INSTANCE_SECRET_ARN_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "arn:aws:secretsmanager:us-east-1:952133486861:secret:rds!db-8c62579e-5edc-459c-91e6-35d1a2b94716-UqmQXc"
  }
  setting {
    name      = "AWS_DB_INSTANCE_USER_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "arn:aws:secretsmanager:us-east-1:952133486861:secret:rds!db-8c62579e-5edc-459c-91e6-35d1a2b94716-UqmQXc:username::"
  }
  setting {
    name      = "AWS_ECR_REPOSITORY_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wp-image"
  }
  setting {
    name      = "AWS_ECR_REPOSITORY_URL_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "952133486861.dkr.ecr.us-east-1.amazonaws.com/wp-image"
  }
  setting {
    name      = "AWS_EFS_ACCESS_POINT_ID_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "fsap-062903c3bff583714"
  }
  setting {
    name      = "AWS_EFS_FILE_SYSTEM_ID_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "fs-01a80eb4655700452"
  }
  setting {
    name      = "AWS_ELASTIC_BEANSTALK_APPLICATION_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "beanstalk-wordpress"
  }
  setting {
    name      = "AWS_SSM_PARAMETER_NAME_ADMIN"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "ebWpAdminPassword"
  }
  setting {
    name      = "EnvironmentType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "LoadBalanced"
  }
  setting {
    name      = "InstanceTypes"
    namespace = "aws:ec2:instances"
    value     = "t4g.small"
  }
  setting {
    name      = "LoadBalancerIsShared"
    namespace = "aws:elasticbeanstalk:environment"
    value     = true
  }
  setting {
    name      = "LoadBalancerType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "application"
  }
  setting {
    name      = "MaxSize"
    namespace = "aws:autoscaling:asg"
    value     = "4"
  }
  setting {
    name      = "MinSize"
    namespace = "aws:autoscaling:asg"
    value     = "2"
  }
  setting {
    name      = "NAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "beanstalk-wordpress-web"
  }
  setting {
    name      = "REGION"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "us-east-1"
  }
  setting {
    name      = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "sg-0512cd0577cdc6f5f"
  }
  setting {
    name      = "SecurityGroups"
    namespace = "aws:elbv2:loadbalancer"
    value     = join(",", aws_lb.wp-shared-alb.security_groups)
  }
  setting {
    name      = "SharedLoadBalancer"
    namespace = "aws:elbv2:loadbalancer"
    value     = aws_lb.wp-shared-alb.arn
  }
  setting {
    name      = "SupportedArchitectures"
    namespace = "aws:ec2:instances"
    value     = "arm64"
  }
  setting {
    name      = "VPCId"
    namespace = "aws:ec2:vpc"
    value     = aws_vpc.vpc-beanstalk-wordpress.id
  }
  setting {
    name      = "Subnets"
    namespace = "aws:ec2:vpc"
    value     = "${aws_subnet.wp-app-a.id},${aws_subnet.wp-app-b.id}"
  }
  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_iam_instance_profile.beanstalk-wordpress-web_profile.name
  }
  tags = {
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_lb_listener.wp-shared-http]
}
