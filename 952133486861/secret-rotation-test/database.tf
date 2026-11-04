resource "aws_db_instance" "rotation-db-ignored" {
  db_subnet_group_name     = aws_db_subnet_group.subnet_group_rotation-db-ignored.name
  allocated_storage        = 20
  apply_immediately        = true
  availability_zone        = aws_subnet.rotation-a.availability_zone
  backup_retention_period  = 0
  copy_tags_to_snapshot    = true
  engine                   = "mysql"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  engine_version           = "8.4"
  identifier               = "rotation-db-ignored"
  instance_class           = "db.t3.micro"
  max_allocated_storage    = 100
  password                 = "DummyInitialDbIgnored1"
  skip_final_snapshot      = true
  storage_encrypted        = true
  storage_type             = "gp3"
  upgrade_storage_config   = false
  username                 = "admin"
  vpc_security_group_ids   = [aws_security_group.db_instance_rotation-db-ignored_group.id]
  lifecycle {
    ignore_changes = [password]
  }
  tags = {
    Name           = "rotation-db-ignored"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_instance" "rotation-db-plain" {
  db_subnet_group_name     = aws_db_subnet_group.subnet_group_rotation-db-plain.name
  allocated_storage        = 20
  apply_immediately        = true
  availability_zone        = aws_subnet.rotation-a.availability_zone
  backup_retention_period  = 0
  copy_tags_to_snapshot    = true
  engine                   = "mysql"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  engine_version           = "8.4"
  identifier               = "rotation-db-plain"
  instance_class           = "db.t3.micro"
  max_allocated_storage    = 100
  password                 = "DummyInitialDbPlain1"
  skip_final_snapshot      = true
  storage_encrypted        = true
  storage_type             = "gp3"
  upgrade_storage_config   = false
  username                 = "admin"
  vpc_security_group_ids   = [aws_security_group.db_instance_rotation-db-plain_group.id]
  tags = {
    Name           = "rotation-db-plain"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_subnet_group" "subnet_group_rotation-db-ignored" {
  name       = "rotation-db-ignored-subnet-group"
  subnet_ids = [aws_subnet.rotation-a.id, aws_subnet.rotation-b.id]
  tags = {
    Name           = "subnet_group_rotation-db-ignored"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_subnet_group" "subnet_group_rotation-db-plain" {
  name       = "rotation-db-plain-subnet-group"
  subnet_ids = [aws_subnet.rotation-a.id, aws_subnet.rotation-b.id]
  tags = {
    Name           = "subnet_group_rotation-db-plain"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}
