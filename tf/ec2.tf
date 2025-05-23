resource "aws_instance" "backend" {
  ami                  = "ami-075d39ebbca89ed55" # Amazon Linux 2 AMI
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data = templatefile("scripts/backend_user_data.sh", {
    timestamp               = timestamp()
    datadog_api_key         = var.datadog_api_key
    datadog_site            = var.datadog_site
    project_name            = var.project_name
    environment             = var.environment
    monitor_backend_service = var.monitor_backend_service
    datadog_enable_logs     = var.datadog_enable_logs
  })
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = merge(var.datadog_tags, {
    Name    = "${var.project_name}-backend"
    Role    = "backend"
    Service = var.monitor_backend_service
  })
}

resource "aws_instance" "frontend" {
  ami                  = "ami-075d39ebbca89ed55" # Amazon Linux 2 AMI
  instance_type        = "t2.medium"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data = templatefile("scripts/frontend_user_data.sh", {
    timestamp                = timestamp()
    datadog_api_key          = var.datadog_api_key
    datadog_site             = var.datadog_site
    project_name             = var.project_name
    environment              = var.environment
    monitor_frontend_service = var.monitor_frontend_service
    datadog_enable_logs      = var.datadog_enable_logs
  })
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  tags = merge(var.datadog_tags, {
    Name    = "${var.project_name}-frontend"
    Role    = "frontend"
    Service = var.monitor_frontend_service
  })
}
