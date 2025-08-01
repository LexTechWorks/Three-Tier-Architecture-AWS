output "root_record" {
  description = "Registro root (sem www)"
  value       = aws_route53_record.root.fqdn
}

output "www_record" {
  description = "Registro www"
  value       = aws_route53_record.www.fqdn
}

output "bucket_name" {
  value = aws_s3_bucket.redirect_www.bucket
}
