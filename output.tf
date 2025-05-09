output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.ebs_alerts.arn
}

output "filtered_volume_ids" {
  description = "List of EBS volume IDs being monitored"
  value       = local.filtered_volumes
}
