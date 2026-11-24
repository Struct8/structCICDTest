resource "aws_db_subnet_group" "subnet_group_wp-aurora" {
  name       = "wp-aurora-subnet-group"
  subnet_ids = [aws_subnet.dataA.id, aws_subnet.dataB.id]
  tags = {
    Name           = "subnet_group_wp-aurora"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_rds_cluster" "wp-aurora" {
  database_name                   = "wordpress"
  db_cluster_parameter_group_name = "default.aurora-mysql8.4"
  db_subnet_group_name            = aws_db_subnet_group.subnet_group_wp-aurora.name
  kms_key_id                      = data.aws_kms_key.kmsWordpress.arn
  apply_immediately               = true
  backup_retention_period         = 7
  cluster_identifier              = "wp-aurora"
  copy_tags_to_snapshot           = true
  database_insights_mode          = "standard"
  enable_http_endpoint            = true
  engine                          = "aurora-mysql"
  engine_lifecycle_support        = "open-source-rds-extended-support"
  engine_version                  = "8.4.mysql_aurora.8.4.8"
  manage_master_user_password     = true
  master_username                 = "dbadmin"
  network_type                    = "IPV4"
  port                            = 3306
  preferred_backup_window         = "06:55-07:25"
  preferred_maintenance_window    = "wed:12:36-wed:13:06"
  skip_final_snapshot             = true
  storage_encrypted               = true
  vpc_security_group_ids          = [aws_security_group.rds_cluster_wp-aurora_group.id]
  serverlessv2_scaling_configuration {
    max_capacity             = 4
    min_capacity             = 0
    seconds_until_auto_pause = 300
  }
  tags = {
    Name                                    = "wp-aurora"
    State                                   = "wordpress-professional"
    Struct8Creator                          = "rmay struct"
    "Struct8:Backup:wpDailyBackup-LG8tjg6d" = true
  }
}

resource "aws_rds_cluster_instance" "wp-aurora-reader" {
  db_parameter_group_name      = "default.aurora-mysql8.4"
  ca_cert_identifier           = "rds-ca-rsa2048-g1"
  cluster_identifier           = aws_rds_cluster.wp-aurora.id
  copy_tags_to_snapshot        = true
  engine                       = aws_rds_cluster.wp-aurora.engine
  identifier                   = "wp-aurora-reader"
  instance_class               = "db.serverless"
  preferred_backup_window      = "06:55-07:25"
  preferred_maintenance_window = "sun:06:35-sun:07:05"
  promotion_tier               = 2
  tags = {
    Name           = "wp-aurora-reader"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_rds_cluster_instance" "wp-aurora-writer" {
  db_parameter_group_name      = "default.aurora-mysql8.4"
  ca_cert_identifier           = "rds-ca-rsa2048-g1"
  cluster_identifier           = aws_rds_cluster.wp-aurora.id
  copy_tags_to_snapshot        = true
  engine                       = aws_rds_cluster.wp-aurora.engine
  identifier                   = "wp-aurora-writer"
  instance_class               = "db.serverless"
  preferred_backup_window      = "06:55-07:25"
  preferred_maintenance_window = "tue:13:00-tue:13:30"
  promotion_tier               = 1
  tags = {
    Name           = "wp-aurora-writer"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_elasticache_replication_group" "wpRedis" {
  kms_key_id                 = data.aws_kms_key.kmsWordpress.arn
  parameter_group_name       = "default.redis7"
  replication_group_id       = "wp-object-cache"
  subnet_group_name          = aws_elasticache_subnet_group.subnet_group_wpRedis.name
  at_rest_encryption_enabled = true
  automatic_failover_enabled = true
  cluster_mode               = "disabled"
  description                = "WordPress object cache for wp_options, postmeta and transients."
  engine_version             = "7.1"
  maintenance_window         = "tue:11:00-tue:12:00"
  node_type                  = "cache.t4g.micro"
  num_cache_clusters         = 2
  security_group_ids         = [aws_security_group.elasticache_replication_group_wpRedis_group.id]
  snapshot_retention_limit   = 7
  snapshot_window            = "08:00-09:00"
  transit_encryption_enabled = true
  tags = {
    Name           = "wpRedis"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_elasticache_subnet_group" "subnet_group_wpRedis" {
  name       = "wpredis-subnet-group"
  subnet_ids = [aws_subnet.dataA.id, aws_subnet.dataB.id]
  tags = {
    Name           = "subnet_group_wpRedis"
    State          = "wordpress-professional"
    Struct8Creator = "rmay struct"
  }
}
