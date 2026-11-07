module "app" {
  source                                                                      = "./modules/app"
  arquivos_bucket                                                             = aws_s3_bucket.arquivos.bucket
  lambda_function_processador_st_modulo_teste_state_doc_extra_statements_json = data.aws_iam_policy_document.lambda_function_processador_st_modulo-teste-state_doc_extra_statements.json
}
