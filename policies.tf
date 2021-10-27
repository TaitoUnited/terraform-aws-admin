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

resource "aws_iam_policy" "kubernetes_connect" {
  count = var.create_predefined_policies == true ? 1 : 0
  name  = "${var.predefined_policy_prefix}kubernetes.connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

/* TODO: not required?
resource "aws_iam_policy" "logging_read" {
  count = var.create_predefined_policies == true ? 1 : 0
  name  = "${var.predefined_policy_prefix}logging.read"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
*/

resource "aws_iam_policy" "logging_write" {
  count = var.create_predefined_policies == true ? 1 : 0
  name  = "${var.predefined_policy_prefix}logging.write"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "serverless_deploy" {
  count  = var.create_predefined_policies == true ? 1 : 0
  name   = "${var.predefined_policy_prefix}serverless.deploy"
  policy = data.aws_iam_policy_document.serverless_deploy.json
}

data "aws_iam_policy_document" "serverless_deploy" {

  # Environment info required on deployment (read-only)
  statement {
    actions = [
      # Kubernetes
      "eks:DescribeCluster",
      "eks:ListClusters",

      # DNS
      "route53:ListHostedZones",
      "route53:GetHostedZone",
      "route53:ListTagsForResource",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",

      # Certificates
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "acm:ListTagsForCertificate",

      # Roles
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
    ]

    resources = [
      "*"
    ]
  }

  # Deploy services
  statement {
    actions = [
      "route53:CreateHealthCheck",
      "iam:PutRolePolicy",
      # TODO: Limit apigateway and lambda actions
      "apigateway:*",
      "lambda:*",
    ]

    resources = [
      "*"
    ]
  }

  # Save static assets to bucket
  dynamic "statement" {
    for_each = var.shared_static_assets_bucket != null ? [1] : []
    content {
      actions = [
        # TODO: limit actions
        "s3:*"
      ]
      resources = [
        "arn:aws:s3:::${var.shared_static_assets_bucket}",
        "arn:aws:s3:::${var.shared_static_assets_bucket}/*"
      ]
    }
  }

  # Save function package to bucket
  dynamic "statement" {
    for_each = var.shared_functions_bucket != null ? [1] : []
    content {
      actions = [
        # TODO: limit actions
        "s3:*"
      ]
      resources = [
        "arn:aws:s3:::${var.shared_functions_bucket}",
        "arn:aws:s3:::${var.shared_functions_bucket}/*"
      ]
    }
  }

  # Store terraform state to bucket
  dynamic "statement" {
    for_each = var.shared_state_bucket != null ? [1] : []
    content {
      actions = [
        # TODO: limit actions
        "s3:*"
      ]
      resources = [
        "arn:aws:s3:::${var.shared_state_bucket}",
        "arn:aws:s3:::${var.shared_state_bucket}/*"
      ]
    }
  }
}

resource "aws_iam_policy" "cicd_secrets_read" {
  count  = var.create_predefined_policies == true && var.cicd_secrets_path != "" ? 1 : 0
  name   = "${var.predefined_policy_prefix}cicd.secrets.read"
  policy = data.aws_iam_policy_document.cicd_secrets_read.json
}

data "aws_iam_policy_document" "cicd_secrets_read" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "arn:aws:secretsmanager::${var.account_id}:secret:${var.cicd_secrets_path}*"
    ]
  }
}

/* TODO: not required?
resource "aws_iam_policy" "cicd_secrets_write" {
  count  = var.create_predefined_policies == true && var.cicd_secrets_path != "" ? 1 : 0
  name   = "${var.predefined_policy_prefix}cicd.secrets.write"
  policy = data.aws_iam_policy_document.cicd_secrets_write.json
}

data "aws_iam_policy_document" "cicd_secrets_write" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:CreateSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:RestoreSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
    ]

    resources = [
      "arn:aws:secretsmanager::${var.account_id}:secret:${var.cicd_secrets_path}*"
    ]
  }
}
*/

/* TODO: not required?
resource "aws_iam_policy" "cdn_publish" {
  count  = var.create_predefined_policies == true && var.shared_static_assets_bucket != "" ? 1 : 0
  name   = "${var.predefined_policy_prefix}cdn.publish"
  policy = data.aws_iam_policy_document.cdn_publish.json
}

data "aws_iam_policy_document" "cdn_publish" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${var.shared_static_assets_bucket}",
      "arn:aws:s3:::${var.shared_static_assets_bucket}/*"
    ]
  }
}
*/
