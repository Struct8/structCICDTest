resource "aws_s3_object" "teste-csv" {
  acl    = "private"
  bucket = module.dados.source_bucket
  content = <<EOF
a,b
1,2
  EOF
  content_type = "text/csv"
  key          = "uploads/x.csv"
  tags = {
    Name           = "teste-csv"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "teste-jpg" {
  acl          = "private"
  bucket       = module.dados.source_bucket
  content      = "not an image, only the suffix matters"
  content_type = "text/plain"
  key          = "y.jpg"
  tags = {
    Name           = "teste-jpg"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
}
