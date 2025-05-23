# ==============================================================================
# DATADOG INTEGRACIÓN CON AWS - PROYECTO LTI
# ==============================================================================

# ------------------------------------------------------------------------------
# OBTENER INFORMACIÓN DE LA CUENTA AWS ACTUAL
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# CREAR POLÍTICA IAM PARA DATADOG
# ------------------------------------------------------------------------------

# Política IAM para la integración AWS-Datadog
resource "aws_iam_policy" "datadog_aws_integration" {
  name        = "${var.project_name}-datadog-integration"
  path        = "/"
  description = "IAM policy for Datadog AWS integration for LTI project"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:List*",
          "cloudwatch:Get*",
          "cloudwatch:Describe*",
          "ec2:Describe*",
          "ec2:Get*",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:GetBucketTagging",
          "iam:ListRoles",
          "iam:ListPolicies"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.datadog_tags
}

# ------------------------------------------------------------------------------
# CREAR ROLE IAM PARA DATADOG
# ------------------------------------------------------------------------------

# Role IAM que Datadog puede asumir
resource "aws_iam_role" "datadog_aws_integration" {
  name = "${var.project_name}-datadog-integration"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.datadog_external_id != "" ? var.datadog_external_id : random_password.external_id.result
          }
        }
      }
    ]
  })

  tags = var.datadog_tags
}

# Attachment del policy al role
resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}

# External ID aleatorio si no se proporciona uno
resource "random_password" "external_id" {
  length  = 32
  special = true
}

# ------------------------------------------------------------------------------
# DASHBOARD DE DATADOG PARA EL PROYECTO LTI
# ------------------------------------------------------------------------------

# Dashboard principal del sistema LTI
resource "datadog_dashboard" "lti_system_overview" {
  title        = "LTI - Sistema de Seguimiento de Talento"
  description  = "Dashboard principal para monitorizar la infraestructura y aplicaciones del Sistema LTI"
  layout_type  = "ordered"
  is_read_only = false

  tags = [
    "team:${var.datadog_tags["team"]}"
  ]

  widget {
    group_definition {
      title            = "Infraestructura EC2"
      layout_type      = "ordered"
      background_color = "blue"

      widget {
        timeseries_definition {
          title = "CPU Utilization - LTI Instances"
          request {
            q            = "avg:aws.ec2.cpuutilization{project:${var.project_name}}"
            display_type = "line"
            style {
              palette = "dog_classic"
            }
          }
          yaxis {
            min = "0"
            max = "100"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Memory Utilization - LTI Instances"
          request {
            q            = "avg:system.mem.pct_usable{project:${var.project_name}} by {host}"
            display_type = "line"
            style {
              palette = "cool"
            }
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title            = "Aplicaciones LTI"
      layout_type      = "ordered"
      background_color = "green"

      widget {
        query_value_definition {
          title = "Backend Service Status"
          request {
            q          = "avg:datadog.agent.up{service:${var.monitor_backend_service}}"
            aggregator = "avg"
          }
          autoscale = true
          precision = 0
        }
      }

      widget {
        query_value_definition {
          title = "Frontend Service Status"
          request {
            q          = "avg:datadog.agent.up{service:${var.monitor_frontend_service}}"
            aggregator = "avg"
          }
          autoscale = true
          precision = 0
        }
      }
    }
  }

  widget {
    group_definition {
      title            = "Logs de Aplicaciones"
      layout_type      = "ordered"
      background_color = "orange"

      widget {
        log_stream_definition {
          title = "Logs recientes del Backend LTI"
          query = "service:${var.monitor_backend_service}"
          sort {
            column = "time"
            order  = "desc"
          }
          columns = ["core_host", "core_service", "message"]
        }
      }

      widget {
        log_stream_definition {
          title = "Logs recientes del Frontend LTI"
          query = "service:${var.monitor_frontend_service}"
          sort {
            column = "time"
            order  = "desc"
          }
          columns = ["core_host", "core_service", "message"]
        }
      }
    }
  }
}

# Monitor de CPU crítico
resource "datadog_monitor" "lti_cpu_critical" {
  name    = "LTI - CPU crítico en instancias"
  type    = "metric alert"
  message = "La CPU en las instancias LTI está por encima del ${var.cpu_threshold_critical}%. @${join(" @", var.alert_email_recipients)}"

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{project:${var.project_name}} > ${var.cpu_threshold_critical}"

  monitor_thresholds {
    warning  = var.cpu_threshold_warning
    critical = var.cpu_threshold_critical
  }

  notify_no_data      = true
  renotify_interval   = 60
  timeout_h           = 0
  include_tags        = true
  require_full_window = false

  tags = [for k, v in var.datadog_tags : "${k}:${v}"]
}

# Monitor de memoria crítica
resource "datadog_monitor" "lti_memory_critical" {
  name    = "LTI - Memoria crítica en instancias"
  type    = "metric alert"
  message = "La memoria en las instancias LTI está por encima del ${var.memory_threshold_critical}%. @${join(" @", var.alert_email_recipients)}"

  query = "avg(last_5m):avg:system.mem.pct_usable{project:${var.project_name}} < ${100 - var.memory_threshold_critical}"

  monitor_thresholds {
    warning  = 100 - var.memory_threshold_warning
    critical = 100 - var.memory_threshold_critical
  }

  notify_no_data      = true
  renotify_interval   = 60
  timeout_h           = 0
  include_tags        = true
  require_full_window = false

  tags = [for k, v in var.datadog_tags : "${k}:${v}"]
}

# ------------------------------------------------------------------------------
# OUTPUTS INFORMATIVOS
# ------------------------------------------------------------------------------

output "datadog_role_arn" {
  value       = aws_iam_role.datadog_aws_integration.arn
  description = "ARN del role IAM para la integración AWS-Datadog"
}

output "datadog_external_id" {
  value       = var.datadog_external_id != "" ? var.datadog_external_id : random_password.external_id.result
  description = "External ID para la integración AWS-Datadog"
  sensitive   = true
}

output "datadog_dashboard_url" {
  value       = "https://app.${var.datadog_site}/dashboard/${datadog_dashboard.lti_system_overview.id}"
  description = "URL del dashboard principal de LTI en Datadog"
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "ID de la cuenta AWS actual"
}
