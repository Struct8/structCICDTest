data "aws_vpc" "demo-mysql-vpc" {
  filter {
    name   = "tag:Name"
    values = ["demo-mysql-vpc"]
  }
}

data "aws_kms_key" "demo-mysql-kms" {
  key_id = "alias/demo-mysql-kms-zJaiUYhB"
}
