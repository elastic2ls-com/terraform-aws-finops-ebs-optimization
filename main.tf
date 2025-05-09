data "aws_ebs_volumes" "all_volumes" {
  count = var.use_fake_data ? 0 : 1
  tags = {
    Environment = var.tag_filter_value
  }
}

data "aws_ebs_volume" "volume_details" {
  for_each = var.use_fake_data ? toset([]) : toset(data.aws_ebs_volumes.all_volumes[0].ids)

  filter {
    name   = "volume-id"
    values = [each.value]
  }
  filter {
    name   = "volume_type"
    values = [each.value]
  }
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

  real_volumes = {
    for vol_id, vol in data.aws_ebs_volume.volume_details :
    vol_id => {
      volume_type = vol.volume_type
      tags        = vol.tags
    }
  }

  fake_volumes = {
    "vol-01" = { volume_type = "gp2", tags = { Environment = "Production" } }
    "vol-02" = { volume_type = "gp3", tags = { Environment = "Production" } }
    "vol-03" = { volume_type = "st1", tags = { Environment = "Production" } }
    "vol-04" = { volume_type = "sc1", tags = { Environment = "Production" } }
    "vol-05" = { volume_type = "io1", tags = { Environment = "Production" } }
    "vol-06" = { volume_type = "io2", tags = { Environment = "Production" } }
  }

  selected_volumes = var.use_fake_data ? local.fake_volumes : local.real_volumes

  ssd_volumes = {
    for vol_id, vol in local.real_volumes :
    vol_id => vol
    if contains(["gp2", "gp3", "io1", "io2"], vol.volume_type)
  }

}