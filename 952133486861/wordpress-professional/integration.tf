resource "aws_sns_topic" "alarmsWordpress" {
  name           = "alarmsWordpress"
  tracing_config = "Active"
  tags = {
    Name           = "alarmsWordpress"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_xray_resource_policy.aws_xray_resource_policy_st_wordpress-professional_6a7eb02276]
}

resource "aws_sns_topic_subscription" "Subscription1" {
  endpoint  = "rbpmconsulting@gmail.com"
  protocol  = "email"
  topic_arn = aws_sns_topic.alarmsWordpress.arn
}

resource "aws_sesv2_email_identity" "wpMail" {
  email_identity = "wp.cloudman.pro"
  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }
  tags = {
    Name           = "wpMail"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}
