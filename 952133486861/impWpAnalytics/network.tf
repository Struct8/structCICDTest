resource "aws_cloudfront_realtime_log_config" "cdnLogConfig" {
  name          = "cdnLogConfig"
  fields        = ["c-country", "cache-behavior-path-pattern", "cs-method", "cs-referer", "cs-uri-query", "cs-uri-stem", "cs-user-agent", "sc-bytes", "sc-status", "time-taken", "timestamp", "x-edge-detailed-result-type", "x-edge-result-type"]
  sampling_rate = 100
  endpoint {
    stream_type = "Kinesis"
    kinesis_stream_config {
      role_arn   = aws_iam_role.cdnLogConfig_role.arn
      stream_arn = "arn:aws:kinesis:us-west-2:952133486861:stream/cdnLogStream"
    }
  }
  depends_on = [aws_iam_role_policy_attachment.cloudfront_realtime_log_config_cdnLogConfig_st_wp-analytics_attach_cdnLogConfig_role]
}

resource "aws_cloudfront_response_headers_policy" "cspReportOnly" {
  name    = "cspReportOnly"
  comment = "Copies the security headers of Managed-SecurityHeadersPolicy and adds a report-only CSP."
  custom_headers_config {
    items {
      header   = "Content-Security-Policy-Report-Only"
      override = true
      value    = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data: https:; connect-src 'self' https:; frame-src 'self' https:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'self'; report-uri https://66wamo3ael2cbfnzramimgscoy0famrj.lambda-url.us-west-2.on.aws/"
    }
  }
  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = false
    }
    referrer_policy {
      override        = false
      referrer_policy = "strict-origin-when-cross-origin"
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = false
      override                   = false
      preload                    = false
    }
    xss_protection {
      mode_block = true
      override   = false
      protection = true
    }
  }
}
