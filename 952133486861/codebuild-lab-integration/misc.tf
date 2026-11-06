resource "time_sleep" "codebuild-lab-integration_role_propagation" {
  create_duration = "30s"
  triggers = {
    policy_attachment = aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration_attach.id
    policy            = aws_iam_policy.codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration.policy
  }
}
