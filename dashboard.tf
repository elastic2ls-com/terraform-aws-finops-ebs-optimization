resource "aws_cloudwatch_dashboard" "ebs_dashboard" {
  count          = var.enable_dashboard ? 1 : 0
  dashboard_name = "ebs-optimization-dashboard"

  dashboard_body = jsonencode({
    widgets = flatten([
      for vol_id, vol in local.selected_volumes : [
        {
          type   = "metric"
          width  = 6
          height = 6
          properties = {
            metrics = [
              ["AWS/EBS", "BurstBalance", "VolumeId", vol_id]
            ]
            period = 300
            stat   = "Average"
            region = var.aws_region
            title  = "BurstBalance ${vol_id}"
          }
        },
        {
          type   = "metric"
          width  = 6
          height = 6
          properties = {
            metrics = [
              ["AWS/EBS", "VolumeReadOps", "VolumeId", vol_id],
              [".", "VolumeWriteOps", ".", ".", { "yAxis" : "right" }]
            ]
            period = 300
            stat   = "Sum"
            region = var.aws_region
            title  = "Read/Write Ops ${vol_id}"
          }
        }
      ]
    ])
  })
}
