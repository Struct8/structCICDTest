data "local_file" "UserData_demo-pgweb" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-pgweb/v1/user_data/pgweb.sh"
}

data "aws_ami" "AMI_Data_Source_demo-pgweb" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "demo-pgweb" {
  subnet_id                   = aws_subnet.demo-public-a.id
  ami                         = data.aws_ami.AMI_Data_Source_demo-pgweb.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.demo-pgweb_profile.name
  instance_type               = "t3.small"
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="demo-pgweb"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
AWS_DB_INSTANCE_NAME_0="${aws_db_instance.demo-postgres.identifier}"
AWS_DB_INSTANCE_ENGINE_0="${aws_db_instance.demo-postgres.engine}"
AWS_DB_INSTANCE_ENDPOINT_0="${aws_db_instance.demo-postgres.endpoint}"
AWS_DB_INSTANCE_DB_NAME_0="${aws_db_instance.demo-postgres.db_name}"
AWS_DB_INSTANCE_SECRET_ARN_0="${one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)}"
AWS_DB_INSTANCE_USER_NAME_0="${one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)}:username::"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_demo-pgweb.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_demo-pgweb_group.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Struct8Debug   = "LWOdB7cr7ocaaK7CXIwEL"
    Name           = "demo-pgweb"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

data "archive_file" "archive_struct8-hub_demo-postgres-api" {
  output_path = "${path.module}/struct8-hub_demo-postgres-api.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "demo-postgres-api" {
  function_name                  = "demo-postgres-api"
  architectures                  = ["arm64"]
  description                    = "API Lambda que consome o banco demo-postgres"
  filename                       = data.archive_file.archive_struct8-hub_demo-postgres-api.output_path
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-postgres-api_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_demo-postgres-api.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                         = "demo-postgres-api"
      REGION                       = data.aws_region.current.region
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_DB_PROXY_NAME_0          = aws_db_proxy.demo-postgres-proxy.name
      AWS_DB_PROXY_ENDPOINT_0      = aws_db_proxy.demo-postgres-proxy.endpoint
      AWS_DB_PROXY_PORT_0          = "5432"
      AWS_DB_PROXY_ENGINE_FAMILY_0 = "POSTGRESQL"
      AWS_DB_PROXY_SECRET_ARN_0    = tolist(aws_db_proxy.demo-postgres-proxy.auth)[0].secret_arn
      AWS_DB_PROXY_DB_NAME_0       = "appdb"
    }
  }
  tags = {
    Name           = "demo-postgres-api"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.demo-postgres-api.id]
    subnet_ids         = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-postgres-api_st_demo-postgres-state_attach]
}

data "archive_file" "archive_struct8-hub_demo-postgres-direct" {
  output_path = "${path.module}/struct8-hub_demo-postgres-direct.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "demo-postgres-direct" {
  function_name                  = "demo-postgres-direct"
  architectures                  = ["arm64"]
  description                    = "Lambda que acessa o RDS DIRETO (sem proxy), rodando o Struct8 Hub"
  filename                       = data.archive_file.archive_struct8-hub_demo-postgres-direct.output_path
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-postgres-direct_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_demo-postgres-direct.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                         = "demo-postgres-direct"
      REGION                       = data.aws_region.current.region
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_DB_INSTANCE_NAME_0       = aws_db_instance.demo-postgres.identifier
      AWS_DB_INSTANCE_ENGINE_0     = aws_db_instance.demo-postgres.engine
      AWS_DB_INSTANCE_ENDPOINT_0   = aws_db_instance.demo-postgres.endpoint
      AWS_DB_INSTANCE_DB_NAME_0    = aws_db_instance.demo-postgres.db_name
      AWS_DB_INSTANCE_SECRET_ARN_0 = one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)
      AWS_DB_INSTANCE_USER_NAME_0  = "${one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)}:username::"
    }
  }
  tags = {
    Name           = "demo-postgres-direct"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.demo-postgres-direct.id]
    subnet_ids         = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-postgres-direct_st_demo-postgres-state_attach]
}

data "archive_file" "archive_struct8-hub_demo-postgres-iam" {
  output_path = "${path.module}/struct8-hub_demo-postgres-iam.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "demo-postgres-iam" {
  function_name                  = "demo-postgres-iam"
  architectures                  = ["arm64"]
  description                    = "Lambda que acessa o RDS via IAM database authentication (token, sem senha)"
  filename                       = data.archive_file.archive_struct8-hub_demo-postgres-iam.output_path
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-postgres-iam_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_demo-postgres-iam.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                         = "demo-postgres-iam"
      REGION                       = data.aws_region.current.region
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_DB_INSTANCE_NAME_0       = aws_db_instance.demo-postgres.identifier
      AWS_DB_INSTANCE_ENGINE_0     = aws_db_instance.demo-postgres.engine
      AWS_DB_INSTANCE_ENDPOINT_0   = aws_db_instance.demo-postgres.endpoint
      AWS_DB_INSTANCE_DB_NAME_0    = aws_db_instance.demo-postgres.db_name
      AWS_DB_INSTANCE_SECRET_ARN_0 = one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)
      AWS_DB_INSTANCE_USER_NAME_0  = "${one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)}:username::"
      AWS_DB_INSTANCE_IAM_USER_0   = "lambda_iam"
    }
  }
  tags = {
    Name           = "demo-postgres-iam"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.demo-postgres-iam.id]
    subnet_ids         = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-postgres-iam_st_demo-postgres-state_attach]
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-api" {
  function_name       = aws_lambda_function.demo-postgres-api.function_name
  principal           = "events.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_cloudwatch_event_rule.every-1-minute.arn
  statement_id_prefix = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-api"
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-direct" {
  function_name       = aws_lambda_function.demo-postgres-direct.function_name
  principal           = "events.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_cloudwatch_event_rule.every-1-minute.arn
  statement_id_prefix = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-direct"
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-iam" {
  function_name       = aws_lambda_function.demo-postgres-iam.function_name
  principal           = "events.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_cloudwatch_event_rule.every-1-minute.arn
  statement_id_prefix = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-iam"
}
