resource "aws_s3_bucket" "root_storage_bucket" {
  bucket = "${var.resource_prefix}-rootbucket-terraform"

  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-rootbucket-terraform"
  })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket             = aws_s3_bucket.root_storage_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on         = [aws_s3_bucket.root_storage_bucket]
}

resource "aws_s3_bucket_acl" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    //should be "Enabled" or "Disabled"
    status = "Disabled"
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:DeleteObject"]
    resources = [
      "${aws_s3_bucket.root_storage_bucket.arn}/*",
      aws_s3_bucket.root_storage_bucket.arn]
    principals {
      identifiers = ["arn:aws:iam::${var.ex_databricks_account_id}:root"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/DatabricksAccountId"

      values = [
        var.databricks_account_id
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.aws_iam_policy_document.this.json
  depends_on = [aws_s3_bucket_public_access_block.this]
}
