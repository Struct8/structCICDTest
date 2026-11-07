moved {
  from = aws_iam_policy.lambda_function_order-charge_st_modlab-b
  to   = module.pagamento.aws_iam_policy.lambda_function_order-charge_st_modlab-b
}

moved {
  from = aws_iam_role_policy_attachment.lambda_function_order-charge_st_modlab-b_attach
  to   = module.pagamento.aws_iam_role_policy_attachment.lambda_function_order-charge_st_modlab-b_attach
}

moved {
  from = aws_iam_policy.lambda_function_order-release_st_modlab-b
  to   = module.pagamento.aws_iam_policy.lambda_function_order-release_st_modlab-b
}

moved {
  from = aws_iam_role_policy_attachment.lambda_function_order-release_st_modlab-b_attach
  to   = module.pagamento.aws_iam_role_policy_attachment.lambda_function_order-release_st_modlab-b_attach
}

moved {
  from = aws_lambda_function.order-charge
  to   = module.pagamento.aws_lambda_function.order-charge
}

moved {
  from = aws_cloudwatch_log_group.order-charge-logs
  to   = module.pagamento.aws_cloudwatch_log_group.order-charge-logs
}

moved {
  from = aws_iam_role.order-charge_role
  to   = module.pagamento.aws_iam_role.order-charge_role
}

moved {
  from = aws_lambda_function.order-release
  to   = module.pagamento.aws_lambda_function.order-release
}

moved {
  from = aws_cloudwatch_log_group.order-release-logs
  to   = module.pagamento.aws_cloudwatch_log_group.order-release-logs
}

moved {
  from = aws_iam_role.order-release_role
  to   = module.pagamento.aws_iam_role.order-release_role
}
