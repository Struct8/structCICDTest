resource "aws_iam_instance_profile" "beanstalk-wordpress-web_profile" {
  name = "beanstalk-wordpress-web_profile"
  path = "/"
  role = aws_iam_role.beanstalk-wordpress-web_role.name
  tags = {
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
    Name           = "beanstalk-wordpress-web_profile"
  }
}

data "aws_iam_policy_document" "elastic_beanstalk_environment_beanstalk-wordpress-web_st_beanstalk-wordpress_doc" {
  statement {
    sid       = "AllowRDSSecretAccesswpebdb"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.wp-eb-db.master_user_secret[0].secret_arn]
  }
  statement {
    sid       = "AllowEFSBasicAccess"
    effect    = "Allow"
    actions   = ["elasticfilesystem:ClientMount", "elasticfilesystem:ClientRootAccess", "elasticfilesystem:ClientWrite"]
    resources = ["${aws_efs_file_system.wp-eb-files.arn}:*"]
  }
  statement {
    sid       = "BeanstalkSourceBundle"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.beanstalk-wordpress-versions.arn}/beanstalk/beanstalk-wordpress-web/*"]
  }
  statement {
    sid       = "AllowReadParam"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.ebWpAdminPassword.arn]
  }
  statement {
    sid       = "AllowSecureStringDecrypt"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["ssm.*.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
}

resource "aws_iam_policy" "elastic_beanstalk_environment_beanstalk-wordpress-web_st_beanstalk-wordpress" {
  name        = "elastic_beanstalk_environment_beanstalk-wordpress-web_st_beanstalk-wordpress"
  description = "Access Policy for beanstalk-wordpress-web"
  policy      = data.aws_iam_policy_document.elastic_beanstalk_environment_beanstalk-wordpress-web_st_beanstalk-wordpress_doc.json
}

data "aws_iam_policy_document" "wp-eb-debug_debug_permissions" {
  statement {
    sid       = "SendToTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["-_lph4zcMnpHNJxCwYZbI"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid       = "PinnedDocumentOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe--_lph4zcMnpHNJxCwYZbI"]
  }
  statement {
    sid       = "ReadOwnResults"
    effect    = "Allow"
    actions   = ["ssm:GetCommandInvocation", "ssm:DescribeInstanceInformation"]
    resources = ["*"]
  }
  statement {
    sid       = "CancelOnTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:CancelCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["-_lph4zcMnpHNJxCwYZbI"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
}

data "aws_iam_policy_document" "wp-eb-debug_debug_trust" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CrossAccountStruct8"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "Struct8Debug-wp-eb-debug" {
  name                 = "Struct8Debug--_lph4zcMnpHNJxCwYZbI"
  assume_role_policy   = data.aws_iam_policy_document.wp-eb-debug_debug_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role" "beanstalk-wordpress-web_role" {
  name                  = "beanstalk-wordpress-web_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
    Name           = "beanstalk-wordpress-web_role"
  }
}

resource "aws_iam_role_policy" "Struct8Debug-wp-eb-debug_policy" {
  name   = "Struct8Debug--_lph4zcMnpHNJxCwYZbI-policy"
  policy = data.aws_iam_policy_document.wp-eb-debug_debug_permissions.json
  role   = aws_iam_role.Struct8Debug-wp-eb-debug.id
}

resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkMulticontainerDocker_to_beanstalk-wordpress-web_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
  role       = aws_iam_role.beanstalk-wordpress-web_role.name
}

resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkWebTier_to_beanstalk-wordpress-web_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
  role       = aws_iam_role.beanstalk-wordpress-web_role.name
}

resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkWorkerTier_to_beanstalk-wordpress-web_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  role       = aws_iam_role.beanstalk-wordpress-web_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_beanstalk-wordpress-web_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.beanstalk-wordpress-web_role.name
}

resource "aws_iam_role_policy_attachment" "elastic_beanstalk_environment_beanstalk-wordpress-web_st_beanstalk-wordpress_attach" {
  policy_arn = aws_iam_policy.elastic_beanstalk_environment_beanstalk-wordpress-web_st_beanstalk-wordpress.arn
  role       = aws_iam_role.beanstalk-wordpress-web_role.name
}
