# Example: Basic Usage of terraform-aws-ebs-optimization

This example shows a minimal working configuration of the `terraform-aws-ebs-optimization` module using the **fake data mode**.

It is intended for CI/CD pipelines, testing, and demonstration purposes.

## Usage

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
