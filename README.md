[![Terraform CI](https://github.com/elastic2ls-com/terraform-aws-ebs-optimization/actions/workflows/terraform.yml/badge.svg)](https://github.com/elastic2ls-com/terraform-aws-ebs-optimization/actions)
![License](https://img.shields.io/badge/license-MIT-brightgreen?logo=mit)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?logo=git)
[![Sponsor](https://img.shields.io/badge/sponsors-AlexanderWiechert-blue.svg?logo=github-sponsors)](https://github.com/sponsors/AlexanderWiechert/)
[![Contact](https://img.shields.io/badge/website-elastic2ls.com-blue.svg?logo=google-chrome)](https://www.elastic2ls.com/)
[![Terraform Registry](https://img.shields.io/badge/download-blue.svg?logo=terraform&style=social)](https://registry.terraform.io/modules/elastic2ls-com/ebs-optimization/aws/latest)
![OpenTofu Compatible](https://img.shields.io/badge/OpenTofu-Compatible-4E9A06?logo=opentofu)

# terraform-aws-ebs-optimization

Terraform module to monitor and optimize EBS volumes across an AWS account with dynamic CloudWatch alarms for cost-efficient storage.

Supports both:
- **Real mode** → reads live AWS EBS volumes.
- **Fake mode** → uses local test data (for CI/CD, local testing, or demos).

This module is compatible with both Terraform (>=1.4) and OpenTofu (>=1.4).

---

## Features

- Monitor **BurstBalance**, **ReadOps**, and **WriteOps** per EBS volume.
- Dynamically set alarm thresholds per volume type (gp2, gp3, io1, io2, st1, sc1).
- Automatically exclude irrelevant alarms (e.g., no BurstBalance on st1/sc1).
- Filter volumes by tags (e.g., `Environment = Production`).
- Send alerts to SNS with configurable email subscription.
- Includes example project and CI workflow with security checks.

---

## Usage

### Real Mode (default)

```hcl
module "ebs_optimization" {
  source            = "github.com/elastic2ls-com/terraform-aws-ebs-optimization"
  aws_region       = "eu-central-1"
  tag_filter_key   = "Environment"
  tag_filter_value = "Production"
  sns_topic_name   = "ebs-optimization-alerts"
  email_endpoint   = "finops-team@example.com"
}
```
Run:
```bash
terraform init
terraform plan
terraform apply
```

### Fake Mode (for testing)
```hcl
    module "ebs_optimization" {
    source            = "../../"
    aws_region        = "eu-central-1"
    tag_filter_key    = "Environment"
    tag_filter_value  = "Production"
    sns_topic_name    = "ebs-optimization-alerts"
    email_endpoint    = "finops-team@example.com"
    use_fake_data     = true
}
```
## Security Best Practices

- Use **least privilege** on SNS subscribers.
- Apply **Terraform state encryption** (S3 + KMS) if storing sensitive resources.
- Periodically review alarm thresholds for changes in workload patterns.

---

## Examples

- [Basic Example](./examples/basic/main.tf)

---

## Variables

| Name              | Description                         | Type   | Default            |
|--------------------|-------------------------------------|--------|--------------------|
| aws_region        | AWS region                         | string | "eu-central-1"     |
| tag_filter_key    | Tag key to filter EBS volumes      | string | "Environment"      |
| tag_filter_value  | Tag value to filter EBS volumes    | string | "Production"       |
| sns_topic_name    | Name of the SNS topic for alerts   | string | "ebs-alerts-topic" |
| email_endpoint    | Email address for SNS subscription | string | n/a (required)     |
|use_fake_data	    |Enable fake/test mode (no AWS calls)| 	bool  | false              |

---

## Outputs

| Name                 | Description                     |
|-----------------------|---------------------------------|
| sns_topic_arn        | ARN of the created SNS topic   |
| filtered_volume_ids  | List of monitored EBS volume IDs |

---

## Requirements

- Terraform ≥ 1.4
- AWS Provider ≥ 5.0

---

## CI/CD

This module uses GitHub Actions to run:

- `terraform fmt`
- `terraform validate`
- `terraform plan` on examples
- `checkov` security scan

---

## License

MIT

---

## Maintainers

[elastic2ls](https://github.com/elastic2ls-com)
