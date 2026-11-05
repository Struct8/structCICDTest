resource "time_sleep" "codebuild-lab-pr-check_role_propagation" {
  create_duration = "30s"
  triggers = {
    policy_attachment = aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci_attach.id
    policy            = aws_iam_policy.codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci.policy
  }
}

resource "time_sleep" "codebuild-lab-release_role_propagation" {
  create_duration = "30s"
  triggers = {
    policy_attachment = aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-release_st_codebuild-lab-ci_attach.id
    policy            = aws_iam_policy.codebuild_project_codebuild-lab-release_st_codebuild-lab-ci.policy
  }
}

resource "time_sleep" "codebuild-lab-runner_role_propagation" {
  create_duration = "30s"
  triggers = {
    policy_attachment = aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci_attach.id
    policy            = aws_iam_policy.codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci.policy
  }
}
