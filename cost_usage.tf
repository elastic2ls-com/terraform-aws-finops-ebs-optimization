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
      Action   = "s3:GetBucketAcl"
      Resource = aws_s3_bucket.cur_bucket.arn
      },
      {
        Sid    = "AWSBillingPutObject"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cur_bucket.arn}/*"
    }]
  })
}

resource "aws_athena_database" "cur_database" {
  name    = "cur_database"
  comment = "Athena database for CUR analysis"
  bucket  = aws_s3_bucket.cur_bucket.id
}

resource "aws_athena_data_catalog" "cur_catalog" {
  name        = "AwsDataCatalog"
  description = "Example Athena data catalog"
  type        = "GLUE"
  parameters = {
    "catalog-id" = aws_glue_catalog_table.cur_table.id
  }
}

resource "aws_glue_catalog_table" "cur_table" {
  name          = "cur_table"
  database_name = aws_athena_database.cur_database.name
}


resource "aws_glue_crawler" "cur_crawler" {
  name          = "cur-crawler"
  database_name = aws_athena_database.cur_database.name
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.cur_bucket.bucket}/cur/ebs-report/"
  }
  schedule = "cron(0 2 * * ? *)"
}


resource "aws_iam_role" "glue_crawler_role" {
  name = "glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "glue_crawler_policy" {
  role = aws_iam_role.glue_crawler_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.cur_bucket.arn}",
          "${aws_s3_bucket.cur_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
