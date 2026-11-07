module "pagamento" {
  source                                                              = "./modules/pagamento"
  lambda_function_order_release_st_modlab_b_doc_extra_statements_json = data.aws_iam_policy_document.lambda_function_order-release_st_modlab-b_doc_extra_statements.json
}
