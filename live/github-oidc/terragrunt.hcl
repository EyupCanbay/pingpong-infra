include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/github-oidc"
}

inputs = {
  github_repo = "EyupCanbay/pingpong-app"
}