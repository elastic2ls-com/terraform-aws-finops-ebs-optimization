variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "tag_filter_key" {
  description = "Tag key used to filter EBS volumes"
  type        = string
  default     = "Environment"
}

variable "tag_filter_value" {
  description = "Tag value used to filter EBS volumes"
  type        = string
  default     = "Production"
}

variable "sns_topic_name" {
  description = "SNS topic name for alarms"
  type        = string
  default     = "ebs-alerts-topic"
}

variable "email_endpoint" {
  description = "Email address to subscribe to the SNS topic"
  type        = string
}

variable "use_fake_data" {
  description = "Enable fake data mode for testing"
  type        = bool
  default     = false
}

variable "enable_dashboard" {
  description = "Enable creation of a CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "cost_center" {
  description = "Cost center tag for all resources"
  type        = string
  default     = "FinOps"
}

variable "category_name" {
  description = "Name of the Cost Category"
  type        = string
  default     = "EBS-Volumes"
}