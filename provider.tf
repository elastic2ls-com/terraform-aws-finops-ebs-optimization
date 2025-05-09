provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  default_tags {
    tags = {
      Environment = var.tag_filter_value
      CostCenter  = var.cost_center
      ManagedBy   = "terraform-aws-ebs-optimization"
    }
  }

}
