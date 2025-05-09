resource "aws_athena_named_query" "ebs_cost_by_volumetype" {
  name        = "ebs_cost_by_volumetype"
  database    = aws_athena_database.cur_database.name
  description = "Summarizes EBS costs by volume type"

  query = <<QUERY
SELECT
  product_volume_type AS volume_type,
  SUM(line_item_blended_cost) AS total_cost_usd,
  SUM(line_item_usage_amount) AS total_usage_gib
FROM
  cur_table
WHERE
  product_product_name = 'Amazon Elastic Block Store'
  AND line_item_line_item_type = 'Usage'
GROUP BY
  product_volume_type
ORDER BY
  total_cost_usd DESC;
QUERY
}

resource "aws_athena_named_query" "ebs_cost_by_volume_top20" {
  name        = "ebs_cost_by_volume"
  database    = aws_athena_database.cur_database.name
  description = "Top 20 EBS volumes by cost"

  query = <<QUERY
SELECT
  resource_id AS volume_id,
  SUM(line_item_blended_cost) AS total_cost_usd,
  SUM(line_item_usage_amount) AS total_usage_gib
FROM
  cur_table
WHERE
  product_product_name = 'Amazon Elastic Block Store'
  AND line_item_line_item_type = 'Usage'
GROUP BY
  resource_id
ORDER BY
  total_cost_usd DESC
LIMIT 20;
QUERY
}

resource "aws_athena_named_query" "ebs_monthly_trend" {
  name        = "ebs_monthly_trend"
  database    = aws_athena_database.cur_database.name
  description = "Shows EBS cost trend over months"

  query = <<QUERY
SELECT
  month(bill_billing_period_start_date) AS month,
  year(bill_billing_period_start_date) AS year,
  SUM(line_item_blended_cost) AS total_cost_usd
FROM
  cur_table
WHERE
  product_product_name = 'Amazon Elastic Block Store'
GROUP BY
  year, month
ORDER BY
  year DESC, month DESC;
QUERY
}

resource "aws_athena_named_query" "ebs_cost_by_usagetype" {
  name        = "ebs_cost_by_usagetype"
  database    = aws_athena_database.cur_database.name
  description = "Summarizes EBS costs by usage type"

  query = <<QUERY
SELECT
  usage_type,
  SUM(line_item_blended_cost) AS total_cost_usd
FROM
  cur_table
WHERE
  product_product_name = 'Amazon Elastic Block Store'
GROUP BY
  usage_type
ORDER BY
  total_cost_usd DESC;
QUERY
}

resource "aws_athena_named_query" "ebs_cost_by_costcenter" {
  name        = "ebs_cost_by_costcenter"
  database    = aws_athena_database.cur_database.name
  description = "Summarizes EBS costs by cost center tag"

  query = <<QUERY
SELECT
  resource_tags_costcenter AS cost_center,
  SUM(line_item_blended_cost) AS total_cost_usd
FROM
  cur_table
WHERE
  product_product_name = 'Amazon Elastic Block Store'
GROUP BY
  resource_tags_costcenter
ORDER BY
  total_cost_usd DESC;
QUERY
}
