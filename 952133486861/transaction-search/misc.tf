resource "terraform_data" "transaction-search-us-west-2_reset" {
  input      = data.aws_region.current.region
  depends_on = [aws_xray_trace_segment_destination.transaction-search-us-west-2, aws_cloudwatch_log_resource_policy.transaction-search-us-west-2_spans, aws_xray_indexing_rule.transaction-search-us-west-2_indexing]
  provisioner "local-exec" {
    command = <<EOF
aws xray update-trace-segment-destination --destination XRay --region ${self.input} && aws xray update-indexing-rule --name Default --rule '{"Probabilistic":{"DesiredSamplingPercentage":1}}' --region ${self.input}
    EOF
    interpreter = ["/bin/bash", "-c"]
    when        = destroy
  }
}
