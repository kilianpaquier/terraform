#!/bin/bash

[ -n "$1" ] || { echo "No state name provided"; exit 2; }

# initalize HTTP state with GitLab Terraform State
# copied from https://gitlab.com/to-be-continuous/terraform#how-to-use-gitlab-backend-in-your-development-environment-

MY_PROJECT_PATH="kilianpaquier/terraform"
TF_STATE_NAME="$1"
TF_HTTP_PASSWORD="$GITLAB_TOKEN"

CI_API_V4_URL=https://gitlab.com/api/v4
CI_PROJECT_ID=${MY_PROJECT_PATH//\//%2f}

TF_HTTP_ADDRESS="$CI_API_V4_URL/projects/$CI_PROJECT_ID/terraform/state/$TF_STATE_NAME"
TF_HTTP_LOCK_ADDRESS="$TF_HTTP_ADDRESS/lock"
TF_HTTP_LOCK_METHOD="POST"
TF_HTTP_UNLOCK_ADDRESS="$TF_HTTP_ADDRESS/lock"
TF_HTTP_UNLOCK_METHOD="DELETE"
TF_HTTP_USERNAME="gitlab-token"
TF_HTTP_RETRY_WAIT_MIN="5"

tofu -v
tofu init -reconfigure \
    -backend-config=address="$TF_HTTP_ADDRESS" \
    -backend-config=lock_address="$TF_HTTP_LOCK_ADDRESS" \
    -backend-config=unlock_address="$TF_HTTP_UNLOCK_ADDRESS" \
    -backend-config=username="$TF_HTTP_USERNAME" \
    -backend-config=password="$TF_HTTP_PASSWORD" \
    -backend-config=lock_method="$TF_HTTP_LOCK_METHOD" \
    -backend-config=unlock_method="$TF_HTTP_UNLOCK_METHOD" \
    -backend-config=retry_wait_min="$TF_HTTP_RETRY_WAIT_MIN"
