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

variable "account_id" {
  type = string
  description = "AWS account id"
}

variable "cicd_secrets_path" {
  type = string
  default = ""
  description = "Unique path used to store CI/CD secrets"
}

variable "shared_state_bucket" {
  type = string
  default = ""
  description = "Unique name for the shared bucket used to store Terraform state of different projects"
}

variable "shared_cdn_bucket" {
  type = string
  default = ""
  description = "Unique name for the shared bucket used to store public static assets of different projects"
}

variable "create_predefined_policies" {
  type = bool
  default = true
  description = "If true, a set of predefined policies are created (see policies.tf)."
}

variable "groups" {
  type = list(object({
    name = string
    path = string
    policies = list(string)
    assumeRoles = list(string)
  }))
  default = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "users" {
  type = list(object({
    name = string
    groups = list(string)
  }))
  default = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "roles" {
  type = list(object({
    name = string
    policies = list(string)
    services = list(string)
  }))
  default = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}
