resource "aws_s3_bucket" "code_bucket" {
  bucket = "${var.project_name}-code-bucket-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  acl    = "private"

  tags = var.datadog_tags
}

resource "null_resource" "generate_zip" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = <<EOT
      Remove-Item -Path ./../backend.zip -ErrorAction SilentlyContinue
      Remove-Item -Path ./../frontend.zip -ErrorAction SilentlyContinue
      Compress-Archive -Path ./../backend/* -DestinationPath ./../backend.zip -Force
      Compress-Archive -Path ./../frontend/* -DestinationPath ./../frontend.zip -Force
    EOT
    interpreter = ["PowerShell", "-Command"]
    working_dir = path.module # Ensures paths are relative to the tf directory
  }
}

resource "aws_s3_bucket_object" "backend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "backend.zip"
  source     = "${path.module}/../backend.zip"
  depends_on = [null_resource.generate_zip]
}

resource "aws_s3_bucket_object" "frontend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "frontend.zip"
  source     = "${path.module}/../frontend.zip"
  depends_on = [null_resource.generate_zip]
}
