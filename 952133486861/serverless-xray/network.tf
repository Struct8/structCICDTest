resource "aws_api_gateway_deployment" "xray-demo-deploy" {
  rest_api_id = aws_api_gateway_rest_api.xray-demo-api.id
  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    redeployment = sha1(join(",", [jsonencode([
aws_api_gateway_resource.orders.id,
aws_api_gateway_method.orders-post.id,
aws_api_gateway_integration.orders-lambda-integ.id
])]))
  }
  depends_on = [aws_api_gateway_resource.orders, aws_api_gateway_method.orders-post, aws_api_gateway_integration.orders-lambda-integ]
}

resource "aws_api_gateway_integration" "orders-lambda-integ" {
  resource_id             = aws_api_gateway_resource.orders.id
  rest_api_id             = aws_api_gateway_rest_api.xray-demo-api.id
  http_method             = aws_api_gateway_method.orders-post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api-handler.invoke_arn
  depends_on              = [aws_lambda_permission.perm_aws_api_gateway_rest_api_xray-demo-api_to_api-handler_orders-post]
}

resource "aws_api_gateway_method" "orders-post" {
  resource_id   = aws_api_gateway_resource.orders.id
  rest_api_id   = aws_api_gateway_rest_api.xray-demo-api.id
  authorization = "NONE"
  http_method   = "POST"
}

resource "aws_api_gateway_resource" "orders" {
  parent_id   = aws_api_gateway_rest_api.xray-demo-api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.xray-demo-api.id
  path_part   = "orders"
}

resource "aws_api_gateway_rest_api" "xray-demo-api" {
  name        = "xray-demo-api"
  description = "[Step 1/8 - Entry] REST API, POST /orders. X-Ray tracing is enabled on the stage, so every request starts a trace here that flows through the whole chain. -> forwards to the api-handler (step 2)."
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    Name           = "xray-demo-api"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_api_gateway_stage" "prod2" {
  deployment_id        = aws_api_gateway_deployment.xray-demo-deploy.id
  rest_api_id          = aws_api_gateway_rest_api.xray-demo-api.id
  stage_name           = "prod"
  xray_tracing_enabled = true
  tags = {
    Name           = "prod2"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}
