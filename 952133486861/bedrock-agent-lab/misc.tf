resource "time_sleep" "agent-lab-gateway_role_propagation" {
  create_duration = "30s"
  triggers = {
    role = aws_iam_role.role_agent-lab-gateway.unique_id
  }
}
