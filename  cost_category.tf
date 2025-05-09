resource "aws_ce_cost_category" "ebs_volumes" {
  name         = "EBS-Volumes"
  rule_version = "CostCategoryExpression.v1"

  rule {
    value = "EBS"
    rule {
      dimension {
        key    = "SERVICE"
        values = ["Amazon Elastic Block Store"]
      }
    }
  }

  default_value = "Other"
}
