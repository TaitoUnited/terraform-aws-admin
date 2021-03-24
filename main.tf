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

locals {
  policyArnPrefix = "arn:aws:iam::${var.account_id}:policy/"

  groups = var.groups != null ? var.groups : []
  users = var.users != null ? var.users : []
  roles = var.roles != null ? var.roles : []

  groupsWithAssumeRoles = [
    for group in local.groups: group if length(try(group.assumeRoles, [])) > 0
  ]

  groupPolicies = flatten([
    for group in local.groups: [
      for policy in group.policies:
      {
        key  = "${group.name}-${policy}"
        group = group
        policyArn = replace(policy, "/^arn:/", "") == policy ? "${local.policyArnPrefix}${policy}" : policy
      }
    ]
  ])

  userPolicies = flatten([
    for user in local.users: [
      for policy in user.policies:
      {
        key  = "${user.name}-${policy}"
        user = user
        policyArn = replace(policy, "/^arn:/", "") == policy ? "${local.policyArnPrefix}${policy}" : policy
      }
    ]
  ])

  rolePolicies = flatten([
    for role in local.roles: [
      for policy in role.policies:
      {
        key  = "${role.name}-${policy}"
        role = role
        policyArn = replace(policy, "/^arn:/", "") == policy ? "${local.policyArnPrefix}${policy}" : policy
      }
    ]
  ])
}
