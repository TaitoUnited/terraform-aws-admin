# AWS administration

Example usage:

```
provider "aws" {
  region                  = "us-east-1"
}

module "admin" {
  source              = "TaitoUnited/admin/aws"
  version             = "1.0.0"

  account_id          = "1234567890"

  groups              = yamldecode(file("${path.root}/../infra.yaml"))["groups"]
  users               = yamldecode(file("${path.root}/../infra.yaml"))["users"]
  roles               = yamldecode(file("${path.root}/../infra.yaml"))["roles"]

  # For predefined policies
  create_predefined_policies = true
  cicd_secrets_path          = "/cicd/"
  shared_cdn_bucket          = "shared-cdn"
  shared_state_bucket        = "shared-terraform"
}
```

Example YAML:

```
groups:
  - name: developers
    path: /
    policies: [ "kubernetes.connect", "logging.read" ]
    assumeRoles:
      # Members of the group are allowed to assume a role of an another account
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html
      - "arn:aws:iam::56789012345:role/developer"

users:
  - name: john.doe
    groups: [ "developers" ]
  - name: jane.doe
    groups: [ "developers" ]

roles:
  - name: cicd
    policies: [ "serverless.deploy", "cicd.secrets.read" ]
    services: [ "ec2.amazonaws.com" ]
  - name: logging
    policies: [ "logging.write" ]
    services: [ "ec2.amazonaws.com" ]
```

YAML attributes:

- See variables.tf for all the supported YAML attributes.
- See policies.tf for all the predefined policies.

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/aws)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/aws)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/aws)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/aws)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/aws)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/aws)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/aws)
- [Integrations](https://registry.terraform.io/modules/TaitoUnited/integrations/aws)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

Similar modules are also available for Azure, Google Cloud, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). TIP: See also [AWS project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/aws), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
