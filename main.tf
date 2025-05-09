# Hole alle EBS-Volumes in der Region
data "aws_ebs_volumes" "all_volumes" {}

# Hole Details zu jedem Volume
data "aws_ebs_volume" "volume_details" {
  for_each  = toset(data.aws_ebs_volumes.all_volumes.ids)
  volume_id = each.key
}

locals {
  alarm_thresholds = {
    gp2 = { read_ops = 10, write_ops = 10, burst_balance = 20 }
    gp3 = { read_ops = 100, write_ops = 100, burst_balance = 20 }
    io1 = { read_ops = 500, write_ops = 500, burst_balance = 0 }
    io2 = { read_ops = 500, write_ops = 500, burst_balance = 0 }
    st1 = { read_ops = 5, write_ops = 5, burst_balance = 0 }
    sc1 = { read_ops = 1, write_ops = 1, burst_balance = 0 }
  }

  filtered_volumes = [
    for vol_id, vol in data.aws_ebs_volume.volume_details :
    vol_id
    if contains(keys(vol.tags), var.tag_filter_key)
    && vol.tags[var.tag_filter_key] == var.tag_filter_value
  ]
}

resource "aws_sns_topic" "ebs_alerts" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.ebs_alerts.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}

# BurstBalance (nur SSD)
resource "aws_cloudwatch_metric_alarm" "burst_balance_low" {
  for_each = toset(local.filtered_volumes)
  count    = contains(["gp2", "gp3", "io1", "io2"], data.aws_ebs_volume.volume_details[each.key].volume_type) ? 1 : 0

  alarm_name          = "ebs-burst-balance-low-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BurstBalance"
  namespace           = "AWS/EBS"
  period              = 300
  statistic           = "Average"
  threshold           = local.alarm_thresholds[data.aws_ebs_volume.volume_details[each.key].volume_type].burst_balance
  alarm_description   = "EBS BurstBalance < threshold for volume ${each.key}"
  dimensions = {
    VolumeId = each.key
  }
  alarm_actions = [aws_sns_topic.ebs_alerts.arn]
}

# ReadOps (alle Typen)
resource "aws_cloudwatch_metric_alarm" "read_ops_low" {
  for_each = toset(local.filtered_volumes)

  alarm_name          = "ebs-read-ops-low-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "VolumeReadOps"
  namespace           = "AWS/EBS"
  period              = 300
  statistic           = "Average"
  threshold           = local.alarm_thresholds[data.aws_ebs_volume.volume_details[each.key].volume_type].read_ops
  alarm_description   = "EBS ReadOps < threshold for volume ${each.key}"
  dimensions = {
    VolumeId = each.key
  }
  alarm_actions = [aws_sns_topic.ebs_alerts.arn]
}

# WriteOps (alle Typen)
resource "aws_cloudwatch_metric_alarm" "write_ops_low" {
  for_each = toset(local.filtered_volumes)

  alarm_name          = "ebs-write-ops-low-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "VolumeWriteOps"
  namespace           = "AWS/EBS"
  period              = 300
  statistic           = "Average"
  threshold           = local.alarm_thresholds[data.aws_ebs_volume.volume_details[each.key].volume_type].write_ops
  alarm_description   = "EBS WriteOps < threshold for volume ${each.key}"
  dimensions = {
    VolumeId = each.key
  }
  alarm_actions = [aws_sns_topic.ebs_alerts.arn]
}
