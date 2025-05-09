resource "aws_cloudwatch_metric_alarm" "burst_balance_low" {
  for_each = local.ssd_volumes

  alarm_name          = "ebs-burst-balance-low-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BurstBalance"
  namespace           = "AWS/EBS"
  period              = 300
  statistic           = "Average"
  threshold           = local.alarm_thresholds[each.value.volume_type].burst_balance
  dimensions = {
    VolumeId = each.key
  }
  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "read_ops_low" {
  for_each = local.selected_volumes

  alarm_name          = "ebs-read-ops-low-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "VolumeReadOps"
  namespace           = "AWS/EBS"
  period              = 300
  statistic           = "Average"
  threshold           = local.alarm_thresholds[each.value.volume_type].read_ops
  dimensions = {
    VolumeId = each.key
  }
  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "write_ops_low" {
  for_each = local.selected_volumes

  alarm_name          = "ebs-write-ops-low-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "VolumeWriteOps"
  namespace           = "AWS/EBS"
  period              = 300
  statistic           = "Average"
  threshold           = local.alarm_thresholds[each.value.volume_type].write_ops
  dimensions = {
    VolumeId = each.key
  }
  alarm_actions = []
}

resource "aws_cloudwatch_composite_alarm" "ebs_composite_alarm" {
  for_each = local.selected_volumes

  alarm_name = "ebs-composite-alarm-${each.key}"
  alarm_rule = join(" OR ", compact([
    "ALARM(${aws_cloudwatch_metric_alarm.read_ops_low[each.key].alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.write_ops_low[each.key].alarm_name})",
      contains(keys(local.ssd_volumes), each.key) ? "ALARM(${aws_cloudwatch_metric_alarm.burst_balance_low[each.key].alarm_name})" : ""
  ]))

  alarm_description = "Composite alarm for EBS volume ${each.key}"
  alarm_actions     = [aws_sns_topic.ebs_alerts.arn]

  tags = {
    Environment = var.tag_filter_value
    CostCenter  = var.cost_center
    ManagedBy   = "terraform-aws-ebs-optimization"
  }
  depends_on = [
    aws_cloudwatch_metric_alarm.read_ops_low,
    aws_cloudwatch_metric_alarm.write_ops_low,
    aws_cloudwatch_metric_alarm.burst_balance_low
  ]
}
