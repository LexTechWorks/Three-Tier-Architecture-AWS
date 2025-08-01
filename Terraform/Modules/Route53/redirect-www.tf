resource "aws_s3_bucket" "redirect_www" {
  bucket = "www.${var.domain_name}"

  tags = {
    Name        = "redirect-www"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "redirect_www" {
  bucket = aws_s3_bucket.redirect_www.id

  redirect_all_requests_to {
    host_name = var.domain_name
    protocol  = "https"
  }
}
