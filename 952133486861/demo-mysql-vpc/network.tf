resource "aws_vpc" "demo-mysql-vpc" {
  cidr_block       = "10.7.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "demo-mysql-vpc"
    State          = "demo-mysql-vpc"
    Struct8Creator = "rmay struct"
  }
}
