output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.ebs_alerts.arn
}

output "filtered_volume_ids" {
  value = var.use_fake_data ? [] : data.aws_ebs_volumes.all_volumes[0].ids
}


