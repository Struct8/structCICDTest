moved {
  from = aws_iam_policy.lambda_function_processador_st_modulo-teste-state
  to   = module.app.aws_iam_policy.lambda_function_processador_st_modulo-teste-state
}

moved {
  from = aws_iam_role_policy_attachment.lambda_function_processador_st_modulo-teste-state_attach
  to   = module.app.aws_iam_role_policy_attachment.lambda_function_processador_st_modulo-teste-state_attach
}

moved {
  from = aws_sqs_queue.pedidos
  to   = module.app.aws_sqs_queue.pedidos
}

moved {
  from = aws_lambda_event_source_mapping.pedidos-gatilho
  to   = module.app.aws_lambda_event_source_mapping.pedidos-gatilho
}

moved {
  from = aws_lambda_function.processador
  to   = module.app.aws_lambda_function.processador
}

moved {
  from = aws_iam_role.processador_role
  to   = module.app.aws_iam_role.processador_role
}
