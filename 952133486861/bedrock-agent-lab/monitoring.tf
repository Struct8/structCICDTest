resource "aws_cloudwatch_log_delivery" "agent-lab-gateway_traces" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agent-lab-gateway_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agent-lab-traces_xray.arn
  tags = {
    Name           = "agent-lab-gateway_traces"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_delivery" "agent_lab_memory_traces" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agent_lab_memory_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agent-lab-traces_xray.arn
  tags = {
    Name           = "agent_lab_memory_traces"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_delivery" "agent_lab_orders_traces" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agent_lab_orders_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agent-lab-traces_xray.arn
  tags = {
    Name           = "agent_lab_orders_traces"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_delivery_destination" "agent-lab-traces_xray" {
  name                      = "agent-lab-traces-xray"
  delivery_destination_type = "XRAY"
  tags = {
    Name           = "agent-lab-traces_xray"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_delivery_source" "agent-lab-gateway_traces" {
  name         = "agent-lab-gateway-gateway-traces"
  log_type     = "TRACES"
  resource_arn = aws_bedrockagentcore_gateway.agent-lab-gateway.gateway_arn
  tags = {
    Name           = "agent-lab-gateway_traces"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_delivery_source" "agent_lab_memory_traces" {
  name         = "agent_lab_memory-memory-traces"
  log_type     = "TRACES"
  resource_arn = aws_bedrockagentcore_memory.agent_lab_memory.arn
  tags = {
    Name           = "agent_lab_memory_traces"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_delivery_source" "agent_lab_orders_traces" {
  name         = "agent_lab_orders-runtime-traces"
  log_type     = "TRACES"
  resource_arn = aws_bedrockagentcore_harness.agent_lab_orders.environment_actual[0].agentcore_runtime_environment[0].agent_runtime_arn
  tags = {
    Name           = "agent_lab_orders_traces"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "agent-lab-chat-logs" {
  name              = "/aws/lambda/agent-lab-chat"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "agent-lab-chat-logs"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "agent-lab-orders-tool-logs" {
  name              = "/aws/lambda/agent-lab-orders-tool"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "agent-lab-orders-tool-logs"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_xray_group" "agent-lab-traces" {
  group_name        = "agent-lab-traces"
  filter_expression = "service(\"agent-lab-chat\") OR service(\"agent-lab-orders-tool\")"
  insights_configuration {
    insights_enabled      = false
    notifications_enabled = false
  }
  tags = {
    Name           = "agent-lab-traces"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}
