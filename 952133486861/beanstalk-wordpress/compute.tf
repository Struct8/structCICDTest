resource "aws_elastic_beanstalk_application" "beanstalk-wordpress" {
  name = "beanstalk-wordpress"
  tags = {
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_elastic_beanstalk_environment" "beanstalk-wordpress-web" {
  name                   = "beanstalk-wordpress-web"
  solution_stack_name    = "64bit Amazon Linux 2023 v4.14.0 running Docker"
  application            = aws_elastic_beanstalk_application.beanstalk-wordpress.name
  version_label          = "beanstalk-wordpress-web-97b698ec64eab4b1"
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
    value     = "wp-eb-db.c9g6oy6oylb0.us-west-2.rds.amazonaws.com:3306"
  }
  setting {
    name      = "AWS_DB_INSTANCE_ENGINE_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "mysql"
  }
  setting {
    name      = "AWS_DB_INSTANCE_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "wp-eb-db"
  }
  setting {
    name      = "AWS_DB_INSTANCE_SECRET_ARN_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-a6d6da46-d51d-4f2f-a22e-79cacc7b5185-f9IKZt"
  }
  setting {
    name      = "AWS_DB_INSTANCE_USER_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-a6d6da46-d51d-4f2f-a22e-79cacc7b5185-f9IKZt:username::"
  }
  setting {
    name      = "AWS_EFS_ACCESS_POINT_ID_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "fsap-0d2e63bc587e5c410"
  }
  setting {
    name      = "AWS_EFS_FILE_SYSTEM_ID_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "fs-032e70bbe47a58ff0"
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
    value     = "us-west-2"
  }
  setting {
    name      = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "sg-0be3c5974b974dd1e"
  }
  setting {
    name      = "SupportedArchitectures"
    namespace = "aws:ec2:instances"
    value     = "arm64"
  }
  setting {
    name      = "AWS_SSM_PARAMETER_NAME_0"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "ebWpAdminPassword"
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
    name      = "ELBSubnets"
    namespace = "aws:ec2:vpc"
    value     = "${aws_subnet.wp-public-a.id},${aws_subnet.wp-public-b.id}"
  }
  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_iam_instance_profile.beanstalk-wordpress-web_profile.name
  }
  tags = {
    Struct8Debug   = "-_lph4zcMnpHNJxCwYZbI"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}
