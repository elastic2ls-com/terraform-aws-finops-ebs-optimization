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
