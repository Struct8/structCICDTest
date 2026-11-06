resource "aws_db_subnet_group" "subnet_group_products-aurora" {
  name       = "products-aurora-subnet-group"
  subnet_ids = [aws_subnet.private-a.id, aws_subnet.private-b.id]
  tags = {
    Name           = "subnet_group_products-aurora"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_rds_cluster" "products-aurora" {
  database_name               = "produtos"
  db_subnet_group_name        = aws_db_subnet_group.subnet_group_products-aurora.name
  apply_immediately           = true
  backup_retention_period     = 7
  cluster_identifier          = "products-aurora"
  copy_tags_to_snapshot       = true
  database_insights_mode      = "standard"
  enable_http_endpoint        = true
  engine                      = "aurora-postgresql"
  manage_master_user_password = true
  master_username             = "dbadmin"
  monitoring_interval         = 0
  network_type                = "IPV4"
  port                        = 5432
  skip_final_snapshot         = true
  storage_encrypted           = true
  vpc_security_group_ids      = [aws_security_group.rds_cluster_products-aurora_group.id]
  serverlessv2_scaling_configuration {
    max_capacity             = 4
    min_capacity             = 0
    seconds_until_auto_pause = 300
  }
  tags = {
    Name           = "products-aurora"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_rds_cluster_instance" "products-aurora-instance" {
  cluster_identifier    = aws_rds_cluster.products-aurora.id
  copy_tags_to_snapshot = true
  engine                = aws_rds_cluster.products-aurora.engine
  identifier            = "products-aurora-instance"
  instance_class        = "db.serverless"
  promotion_tier        = 1
  tags = {
    Name           = "products-aurora-instance"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}
