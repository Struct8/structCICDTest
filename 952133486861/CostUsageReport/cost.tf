resource "aws_cur_report_definition" "CURLab" {
  report_name                = "CURLab"
  additional_schema_elements = ["RESOURCES"]
  compression                = "GZIP"
  format                     = "textORcsv"
  refresh_closed_reports     = true
  report_versioning          = "OVERWRITE_REPORT"
  s3_bucket                  = aws_s3_bucket.your-bucket-cost-usage-report.id
  s3_prefix                  = "cur-reports"
  s3_region                  = aws_s3_bucket.your-bucket-cost-usage-report.region
  time_unit                  = "DAILY"
  tags = {
    Name           = "CURLab"
    State          = "CostUsageReport"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_s3_bucket_policy.aws_s3_bucket_policy_your-bucket-cost-usage-report_st_CostUsageReport]
}
