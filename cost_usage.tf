resource "aws_cur_report_definition" "ebs_report" {
  report_name                = "ebs-cost-usage-report"
  time_unit                  = "DAILY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_bucket.id
  s3_region                  = var.aws_region
  s3_prefix                  = "cur/ebs-report"
  report_versioning          = "CREATE_NEW_REPORT"
}

resource "aws_s3_bucket" "cur_bucket" {
  bucket = "finops-obs-optimisation-cur-bucket"
}

resource "aws_s3_bucket_policy" "cur_bucket_policy" {
  bucket = aws_s3_bucket.cur_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AWSBillingPermissions"
      Effect = "Allow"
      Principal = {
        Service = "billingreports.amazonaws.com"
      }
      Action = "s3:GetBucketAcl"
      Resource = aws_s3_bucket.cur_bucket.arn
    },
      {
        Sid    = "AWSBillingPutObject"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.cur_bucket.arn}/*"
      }]
  })
}

resource "aws_athena_database" "cur_database" {
  name          = "cur_database"
  catalog_name  = aws_athena_data_catalog.cur_catalog.name
  comment       = "Athena database for CUR analysis"
  bucket        = aws_s3_bucket.cur_bucket.id
}

resource "aws_athena_named_query" "ebs_query" {
  name        = "ebs_cost_analysis"
  database    = aws_athena_database.cur_database.name
  query       = <<EOF
SELECT line_item_resource_id, product_product_name, line_item_unblended_cost
FROM cur_database.cur_table
WHERE product_product_name = 'Amazon Elastic Block Store'
EOF
  description = "Query to analyze EBS costs"
}
