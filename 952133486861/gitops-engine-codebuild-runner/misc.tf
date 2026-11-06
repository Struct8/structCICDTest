resource "time_sleep" "gitopslab-engine_role_propagation" {
  create_duration = "30s"
  triggers = {
    policy_attachment = aws_iam_role_policy_attachment.codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner_attach.id
    policy            = aws_iam_policy.codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner.policy
  }
}
