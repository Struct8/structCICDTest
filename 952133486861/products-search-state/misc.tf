resource "time_sleep" "init-db-invocation_role_propagation" {
  create_duration = "30s"
  triggers = {
    policy_attachment = aws_iam_role_policy_attachment.lambda_function_lambda-init-db_st_products-search-state_attach.id
    policy            = aws_iam_policy.lambda_function_lambda-init-db_st_products-search-state.policy
  }
}
