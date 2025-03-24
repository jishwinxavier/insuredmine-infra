resource "aws_s3_bucket" "server-access" {
  bucket        = "s3-server-access-logs-nodejsapp"
  force_destroy = true
  tags = {
    resource_name = "s3-server-accesslogs-nodejsapp"
  }
}

resource "aws_s3_bucket_acl" "server-access" {
  bucket     = aws_s3_bucket.server-access.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.server-access]
}

# resource_name to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "server-access" {
  bucket = aws_s3_bucket.server-access.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "server-access" {
  bucket = aws_s3_bucket.server-access.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}