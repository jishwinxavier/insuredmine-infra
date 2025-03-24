resource "aws_s3_bucket" "source" {
  bucket        = "nodejsapp-pipeline"
  force_destroy = true
  tags = {
    resource_name = "s3-nodejsapp"
    resource_GP = "nodejsapp-s3"
  }
}

resource "aws_s3_bucket_acl" "source" {
  bucket = aws_s3_bucket.source.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.source]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "source" {
  bucket = aws_s3_bucket.source.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source" {
    bucket = aws_s3_bucket.source.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  resource "aws_s3_bucket_logging" "source" {
  bucket = aws_s3_bucket.source.id

  target_bucket = aws_s3_bucket.server-access.id
  target_prefix = "/"
}