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

# Política IAM que permite a Datadog leer métricas de CloudWatch y otros servicios
resource "aws_iam_policy" "datadog_aws_integration" {
  name        = "${var.project_name}-datadog-integration-policy"
  description = "Política IAM para integración de Datadog con AWS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:DescribeSecurityGroups",
          "s3:GetBucketLogging",
          "s3:GetBucketLocation",
          "s3:GetBucketNotification",
          "s3:GetBucketVersioning",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "iam:ListAccountAliases",
          "iam:ListRole",
          "iam:ListRoles"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.datadog_tags, {
    Name = "${var.project_name}-datadog-policy"
  })
}

# ------------------------------------------------------------------------------
# CREAR ROLE IAM PARA DATADOG
# ------------------------------------------------------------------------------

# Role IAM que Datadog puede asumir para acceder a AWS
resource "aws_iam_role" "datadog_aws_integration" {
  name        = "${var.project_name}-datadog-integration-role"
  description = "Role IAM para integración de Datadog con AWS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root" # Datadog AWS Account
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.datadog_external_id
          }
        }
      }
    ]
  })

  tags = merge(var.datadog_tags, {
    Name = "${var.project_name}-datadog-role"
  })
}

# Adjuntar la política al role
resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}

# ------------------------------------------------------------------------------
# DASHBOARD DE DATADOG PARA EL PROYECTO LTI
# ------------------------------------------------------------------------------

resource "datadog_dashboard" "lti_monitoring" {
  title       = "Sistema de Seguimiento de Talento (LTI) - Dashboard Principal"
  description = "Dashboard completo para monitorización del Sistema de Seguimiento de Talento"
  layout_type = "ordered"

  # Widget - Resumen del sistema
  widget {
    note_definition {
      content          = "# 📊 Sistema de Seguimiento de Talento (LTI)\n\n**Ambiente**: ${var.environment}\n**Región AWS**: ${var.aws_region}\n**Proyecto**: ${var.project_name}\n\n---\n\n## 🎯 Servicios Monitoreados\n- **Backend**: Node.js/Express con Prisma\n- **Frontend**: React Application\n\n## 📈 Métricas Disponibles\n- CPU y Memoria de servidores EC2\n- Métricas de AWS CloudWatch\n- Logs de aplicación\n\n**Configuración manual requerida**: \nPara completar la integración, configure manualmente la conexión AWS-Datadog en la consola de Datadog usando el Role ARN generado."
      background_color = "blue"
      font_size        = "14"
      text_align       = "left"
      show_tick        = false
      tick_edge        = "left"
      tick_pos         = "50%"
    }
  }

  # Widget - CPU Usage Backend
  widget {
    timeseries_definition {
      title       = "🖥️ CPU Usage - Backend Servers"
      show_legend = true
      legend_size = "small"

      request {
        q            = "avg:aws.ec2.cpuutilization{name:*backend*} by {host}"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }

      yaxis {
        min   = "0"
        max   = "100"
        scale = "linear"
        label = "CPU %"
      }
    }
  }

  # Widget - Memory Usage Backend
  widget {
    timeseries_definition {
      title       = "💾 Memory Usage - Backend Servers"
      show_legend = true
      legend_size = "small"

      request {
        q            = "avg:system.mem.pct_usable{name:*backend*} by {host}"
        display_type = "line"
        style {
          palette    = "purple"
          line_type  = "solid"
          line_width = "normal"
        }
      }

      yaxis {
        min   = "0"
        max   = "100"
        scale = "linear"
        label = "Memory %"
      }
    }
  }

  # Tags del dashboard
  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "team:infrastructure",
    "managed-by:terraform"
  ]
}

# ------------------------------------------------------------------------------
# OUTPUTS INFORMATIVOS
# ------------------------------------------------------------------------------

output "datadog_aws_role_arn" {
  description = "ARN del role IAM creado para Datadog - Usar este ARN para configurar la integración manualmente en Datadog"
  value       = aws_iam_role.datadog_aws_integration.arn
}

output "datadog_dashboard_url" {
  description = "URL del dashboard principal de LTI en Datadog"
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.lti_monitoring.id}"
}

output "datadog_external_id" {
  description = "External ID para usar en la configuración manual de la integración Datadog-AWS"
  value       = var.datadog_external_id
  sensitive   = true
}

output "aws_account_id" {
  description = "Account ID de AWS para configurar en Datadog"
  value       = data.aws_caller_identity.current.account_id
}
