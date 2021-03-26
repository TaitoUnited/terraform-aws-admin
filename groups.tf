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

resource "aws_iam_group" "group" {
  for_each = {for item in local.groups: item.key => item}
  name     = each.value.name
  path     = each.value.path
}

resource "aws_iam_group_policy_attachment" "group_policy" {
  depends_on = [
    aws_iam_group.group,
    aws_iam_policy.kubernetes_connect,
    aws_iam_policy.logging_read,
    aws_iam_policy.logging_write,
    aws_iam_policy.serverless_deploy,
    aws_iam_policy.cicd_secrets_read,
    aws_iam_policy.cicd_secrets_write,
    aws_iam_policy.cdn_publish
  ]

  for_each   = {for item in local.groupPolicies: item.key => item}
  group      = each.value.group.name
  policy_arn = each.value.policyArn
}

resource "aws_iam_group_policy" "group_assume_role_policy" {
  depends_on = [ aws_iam_group.group, aws_iam_role.role ]

  for_each   = {for item in local.groupsWithAssumeRoles: item.key => item}
  name       = "${each.value.name}-assumes-roles"
  group      = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect: "Allow"
      Action: "sts:AssumeRole"
      Resource: each.value.assumeRoles
    }
  })
}
