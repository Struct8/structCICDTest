resource "aws_cloudwatch_log_group" "bedrock-rag-handler-logs" {
  name              = "/aws/lambda/bedrock-rag-handler"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "bedrock-rag-handler-logs"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}
