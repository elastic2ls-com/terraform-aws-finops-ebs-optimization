resource "aws_sns_topic" "ebs_alerts" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.ebs_alerts.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}
