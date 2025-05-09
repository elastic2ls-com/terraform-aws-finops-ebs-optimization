module "ebs_optimization" {
  source = "../../"

  aws_region       = "eu-central-1"
  tag_filter_key   = "Environment"
  tag_filter_value = "Production"
  sns_topic_name   = "ebs-optimization-alerts"
  email_endpoint   = "finops-team@example.com"
  use_fake_data     = true
}
