resource "aws_bedrock_guardrail" "agent-lab-guardrail" {
  name                      = "agent-lab-guardrail"
  blocked_input_messaging   = "I can only help with Bean Lab Coffee orders. Ask about an order by its id, for example: What is the status of order 1001?"
  blocked_outputs_messaging = "I can only help with Bean Lab Coffee orders."
  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "NONE"
      type            = "PROMPT_ATTACK"
    }
  }
  sensitive_information_policy_config {
    pii_entities_config {
      action        = "ANONYMIZE"
      input_action  = "ANONYMIZE"
      output_action = "ANONYMIZE"
      type          = "EMAIL"
    }
  }
  tags = {
    Name           = "agent-lab-guardrail"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
  topic_policy_config {
    topics_config {
      name       = "Travel"
      definition = "Planning or taking trips: destinations, routes and transport between cities or countries, flights, trains, hotels, tourism and visas."
      examples   = ["How can I get to Paris?", "What is the cheapest flight to Lisbon?", "Which hotels are near the Eiffel Tower?", "Do I need a visa to visit Japan?"]
      type       = "DENY"
    }
    topics_config {
      name       = "General knowledge"
      definition = "Facts about geography, history, science, politics, sports and famous people, such as capitals, dates of events, records and definitions."
      examples   = ["What is the capital of France?", "Who won the last World Cup?", "When did World War II end?", "How far is the Moon from Earth?"]
      type       = "DENY"
    }
  }
}

resource "aws_bedrockagentcore_gateway" "agent-lab-gateway" {
  name            = "agent-lab-gateway"
  authorizer_type = "AWS_IAM"
  exception_level = "DEBUG"
  protocol_type   = "MCP"
  role_arn        = aws_iam_role.role_agent-lab-gateway.arn
  tags = {
    Name           = "agent-lab-gateway"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.bedrockagentcore_gateway_agent-lab-gateway_st_bedrock-agent-lab_attach]
}

resource "aws_bedrockagentcore_gateway_target" "orders" {
  name               = "orders"
  gateway_identifier = aws_bedrockagentcore_gateway.agent-lab-gateway.gateway_id
  credential_provider_configuration {
    gateway_iam_role {
    }
  }
  target_configuration {
    mcp {
      lambda {
        lambda_arn = aws_lambda_function.agent-lab-orders-tool.arn
        tool_schema {
          inline_payload {
            name        = "get_order_status"
            description = "Returns the status, item and quantity of one order, looked up by its order id. Call it only with an order id the customer gave."
            input_schema {
              type = "object"
              property {
                name        = "order_id"
                description = "The order id the customer gave."
                required    = true
                type        = "string"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [time_sleep.agent-lab-gateway_role_propagation]
}

resource "aws_bedrockagentcore_harness" "agent_lab_orders" {
  harness_name       = "agent_lab_orders"
  allowed_tools      = ["@agent-lab-gateway"]
  execution_role_arn = aws_iam_role.role_agent_lab_orders.arn
  max_iterations     = 10
  max_tokens         = 4096
  timeout_seconds    = 90
  lifecycle {
    ignore_changes = [environment, memory, environment_variables]
  }
  memory {
    agentcore_memory_configuration {
      arn = aws_bedrockagentcore_memory.agent_lab_memory.arn
      retrieval_config {
        strategy_id     = "session_summaries-N10xKGCTWm"
        map_block_key   = "/summaries/{actorId}/"
        relevance_score = 0.2
        top_k           = 10
      }
    }
  }
  model {
    bedrock_model_config {
      model_id    = "amazon.nova-lite-v1:0"
      api_format  = "converse_stream"
      max_tokens  = 1024
      temperature = 0.2
    }
  }
  system_prompt {
    text = "You are the order assistant of Bean Lab Coffee, a fictional coffee roaster used in a lab. Answer only questions about Bean Lab Coffee orders. If a question is about anything else, reply that you can only help with Bean Lab Coffee orders, and do not answer it. To learn the status of an order, call the get_order_status tool with the order id, even when the user context mentions that order, since its status may have changed. The user context, when present, summarizes this customer's earlier conversations: use it to answer questions about them and to find an order id the customer already gave. Never make up order details; if the tool says an order was not found, say so. Use only an order id that the question or the user context gives, never one you guess; when neither gives one, ask the customer for it. Keep answers short."
  }
  tags = {
    Name           = "agent_lab_orders"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
  tool {
    name = "agent-lab-gateway"
    type = "agentcore_gateway"
    config {
      agentcore_gateway {
        gateway_arn = aws_bedrockagentcore_gateway.agent-lab-gateway.gateway_arn
        outbound_auth {
          aws_iam = true
        }
      }
    }
  }
  truncation {
    strategy = "sliding_window"
    config {
      sliding_window {
        messages_count = 150
      }
    }
  }
  depends_on = [aws_iam_role_policy_attachment.bedrockagentcore_harness_agent_lab_orders_st_bedrock-agent-lab_attach]
}

resource "aws_bedrockagentcore_memory" "agent_lab_memory" {
  name                  = "agent_lab_memory"
  encryption_key_arn    = aws_kms_key.agent-lab-key.arn
  event_expiry_duration = 30
  tags = {
    Name           = "agent_lab_memory"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_bedrockagentcore_memory_strategy" "session_summaries" {
  memory_id           = aws_bedrockagentcore_memory.agent_lab_memory.id
  name                = "session_summaries"
  namespace_templates = ["/summaries/{actorId}/{sessionId}"]
  type                = "SUMMARIZATION"
}
