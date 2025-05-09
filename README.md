[![Terraform CI](https://github.com/elastic2ls-com/terraform-aws-finops-costreview-access/actions/workflows/terraform.yml/badge.svg)](https://github.com/elastic2ls-com/terraform-aws-finops-costreview-access/actions)
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
- Creates a Cost Category in AWS Cost Explorer to group and track all EBS-related costs.
- Filter volumes by tags (e.g., `Environment = Production`).
- Send alerts to SNS with configurable email subscription.
- Adds CloudWatch Composite Alarms to combine ReadOps, WriteOps, and BurstBalance alerts per EBS volume.
- **Optional CloudWatch dashboard** with dynamic widgets per volume.
- Creates Athena Named Queries for EBS cost and usage analysis (requires CUR + Glue + Athena setup).
- Includes example project and CI workflow with security checks.
---

## Usage

### Least Privilege IAM Policy

Before applying this module, ensure the IAM user or role has at least the permissions defined in [`iam-policy-minimal.json`](./iam-policy-minimal.json).

These include:
- CloudWatch: alarm management, metrics read access
- SNS: topic management, publish/subscribe

This avoids running Terraform with overly broad permissions.


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

### Optional CloudWatch Dashboard
```hcl
  enable_dashboard = true
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
|enable_dashboard	|Enable CloudWatch dashboard creation|	bool	|true |
---
### Tagging

This module automatically applies consistent tags to all resources (SNS topics, CloudWatch alarms, dashboards) it creates, making it easier to track costs, ownership, and environments.

The following tags are applied:

| Tag         | Description                                                                                                                                      |
|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| `Environment` | Taken from `var.tag_filter_value`. Ensures the monitoring resources are labeled consistently with the EBS volumes they are watching (e.g., `Production`). |
| `CostCenter`  | Taken from `var.cost_center`. Allows cost allocation and reporting by project, team, or budget owner (default: `FinOps`).                          |
| `ManagedBy`   | Fixed tag (`terraform-aws-ebs-optimization`). Indicates the resources are managed by this Terraform module, improving transparency and auditability. |

**Important:**
- The `Environment` tag does not dynamically read the EBS volume’s tags.
- It uses the value you pass as `tag_filter_value` in the module inputs.
- For example, if you filter volumes with `tag_filter_value = "Production"`, the same value is applied as the `Environment` tag on the monitoring resources.

---

## Outputs

| Name                 | Description                     |
|-----------------------|---------------------------------|
| sns_topic_arn        | ARN of the created SNS topic   |
| filtered_volume_ids  | List of monitored EBS volume IDs |

---
## Athena Named Queries

This module automatically creates useful Athena Named Queries for analyzing EBS costs and usage from the AWS Cost and Usage Report (CUR). These queries help FinOps teams, engineers, and analysts quickly identify optimization opportunities.

The following queries are included:

| Query Name             | Description                                                |
|------------------------|-----------------------------------------------------------|
| `ebs_cost_by_volumetype` | Summarizes EBS costs by volume type (`gp2`, `gp3`, etc.) |
| `ebs_cost_by_volume`     | Shows the top 20 most expensive EBS volumes             |
| `ebs_monthly_trend`      | Displays monthly cost trends over time                 |
| `ebs_cost_by_usagetype` | Breaks down costs by usage type (e.g., volumes, snapshots) |
| `ebs_cost_by_costcenter` | Aggregates costs by CostCenter tag (if CUR tagging is enabled) |

These Named Queries appear in the **AWS Athena console** under Saved Queries and can be executed directly or integrated into reporting and dashboard tools.

### Using Athena Named Queries
After deployment, go to the AWS Athena console → Saved Queries → select and run the EBS cost analysis queries.

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
