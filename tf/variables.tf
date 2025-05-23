# ==============================================================================
# VARIABLES GENERALES DEL PROYECTO LTI
# ==============================================================================

variable "project_name" {
  description = "Nombre del proyecto LTI"
  type        = string
  default     = "lti-project"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Región de AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

# ==============================================================================
# VARIABLES ESPECÍFICAS DE DATADOG
# ==============================================================================

variable "datadog_api_key" {
  description = "API Key de Datadog para autenticación"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.datadog_api_key) > 0
    error_message = "La API Key de Datadog no puede estar vacía."
  }
}

variable "datadog_api_url" {
  description = "URL del API de Datadog"
  type        = string
  default     = "https://api.datadoghq.com/"
}

variable "datadog_site" {
  description = "Sitio de Datadog (us1, us3, us5, eu1, etc.)"
  type        = string
  default     = "datadoghq.com"
}

# ==============================================================================
# CONFIGURACIÓN DEL AGENTE DATADOG
# ==============================================================================

variable "datadog_agent_version" {
  description = "Versión del agente de Datadog a instalar"
  type        = string
  default     = "latest"
}

variable "datadog_enable_logs" {
  description = "Habilitar recolección de logs en el agente Datadog"
  type        = bool
  default     = true
}

variable "datadog_enable_apm" {
  description = "Habilitar Application Performance Monitoring"
  type        = bool
  default     = true
}

variable "datadog_log_level" {
  description = "Nivel de log del agente Datadog (INFO, WARN, ERROR, DEBUG)"
  type        = string
  default     = "INFO"
  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.datadog_log_level)
    error_message = "El nivel de log debe ser uno de: DEBUG, INFO, WARN, ERROR."
  }
}

# ==============================================================================
# CONFIGURACIÓN DE MONITORIZACIÓN ESPECÍFICA PARA LTI
# ==============================================================================

variable "monitor_backend_service" {
  description = "Nombre del servicio backend en Datadog"
  type        = string
  default     = "lti-backend"
}

variable "monitor_frontend_service" {
  description = "Nombre del servicio frontend en Datadog"
  type        = string
  default     = "lti-frontend"
}

variable "alert_email_recipients" {
  description = "Lista de emails que recibirán alertas de Datadog"
  type        = list(string)
  default     = []
}

variable "cpu_threshold_warning" {
  description = "Umbral de CPU para alertas de warning (porcentaje)"
  type        = number
  default     = 70
  validation {
    condition     = var.cpu_threshold_warning >= 0 && var.cpu_threshold_warning <= 100
    error_message = "El umbral de CPU debe estar entre 0 y 100."
  }
}

variable "cpu_threshold_critical" {
  description = "Umbral de CPU para alertas críticas (porcentaje)"
  type        = number
  default     = 85
  validation {
    condition     = var.cpu_threshold_critical >= 0 && var.cpu_threshold_critical <= 100
    error_message = "El umbral crítico de CPU debe estar entre 0 y 100."
  }
}

variable "memory_threshold_warning" {
  description = "Umbral de memoria para alertas de warning (porcentaje)"
  type        = number
  default     = 80
  validation {
    condition     = var.memory_threshold_warning >= 0 && var.memory_threshold_warning <= 100
    error_message = "El umbral de memoria debe estar entre 0 y 100."
  }
}

variable "memory_threshold_critical" {
  description = "Umbral de memoria para alertas críticas (porcentaje)"
  type        = number
  default     = 90
  validation {
    condition     = var.memory_threshold_critical >= 0 && var.memory_threshold_critical <= 100
    error_message = "El umbral crítico de memoria debe estar entre 0 y 100."
  }
}

# ==============================================================================
# CONFIGURACIÓN DE INTEGRACIÓN AWS-DATADOG
# ==============================================================================

variable "aws_account_id" {
  description = "ID de la cuenta de AWS para la integración con Datadog"
  type        = string
  default     = ""
}

variable "datadog_external_id" {
  description = "External ID para el role de AWS usado por Datadog"
  type        = string
  default     = ""
}

variable "datadog_aws_services" {
  description = "Servicios de AWS a monitorear con Datadog"
  type        = list(string)
  default = [
    "ec2",
    "cloudwatch",
    "s3",
    "iam"
  ]
}

# ==============================================================================
# CONFIGURACIÓN DE TAGS PARA DATADOG
# ==============================================================================

variable "datadog_tags" {
  description = "Tags comunes para todos los recursos de Datadog"
  type        = map(string)
  default = {
    Project     = "lti-talent-tracking"
    Environment = "dev"
    ManagedBy   = "terraform"
    Service     = "monitoring"
  }
}

variable "backend_tags" {
  description = "Tags específicos para el monitoreo del backend"
  type        = list(string)
  default = [
    "service:lti-backend",
    "team:backend",
    "component:api"
  ]
}

variable "frontend_tags" {
  description = "Tags específicos para el monitoreo del frontend"
  type        = list(string)
  default = [
    "service:lti-frontend",
    "team:frontend",
    "component:webapp"
  ]
}
