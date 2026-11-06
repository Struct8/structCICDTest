resource "aws_db_snapshot" "DBSnapshot" {
  db_instance_identifier = "demo-mysql"
  db_snapshot_identifier = "dbsnapshot"
  tags = {
    Name           = "DBSnapshot"
    State          = "demo-mysql-snapshot"
    Struct8Creator = "rmay struct"
  }
}
