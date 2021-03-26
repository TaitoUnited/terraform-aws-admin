/**
 * Copyright 2021 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "aws_iam_user" "user" {
  for_each   = {for item in local.users: item.key => item}
  name       = each.value.name
}

resource "aws_iam_user_group_membership" "user_group" {
  depends_on = [ aws_iam_user.user, aws_iam_group.group ]
  for_each   = {for item in local.users: item.key => item}
  user       = each.value.name
  groups     = each.value.groups
}

resource "aws_iam_user_policy_attachment" "user_policy" {
  depends_on = [
    aws_iam_user.user,
    aws_iam_policy.kubernetes_connect,
    aws_iam_policy.logging_read,
    aws_iam_policy.logging_write,
    aws_iam_policy.serverless_deploy,
    aws_iam_policy.cicd_secrets_read,
    aws_iam_policy.cicd_secrets_write,
    aws_iam_policy.cdn_publish
  ]

  for_each   = {for item in local.userPolicies: item.key => item}
  user       = each.value.user.name
  policy_arn = each.value.policyArn
}
