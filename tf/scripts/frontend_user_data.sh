#!/bin/bash

# ==============================================================================
# FRONTEND USER DATA SCRIPT - LTI PROJECT CON DATADOG
# ==============================================================================

# Actualizar sistema e instalar dependencias básicas
sudo yum update -y
sudo yum install -y docker curl

# Iniciar el servicio de Docker
sudo service docker start

# ==============================================================================
# INSTALACIÓN Y CONFIGURACIÓN DEL AGENTE DATADOG
# ==============================================================================

echo "Installing Datadog agent for LTI Frontend..."

# Instalar el agente Datadog
DD_API_KEY="${datadog_api_key}" DD_SITE="${datadog_site}" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configurar tags básicos para el agente
sudo sed -i "s/# tags:/tags:\n  - project:${project_name}\n  - environment:${environment}\n  - service:${monitor_frontend_service}\n  - role:frontend/" /etc/datadog-agent/datadog.yaml

# Habilitar logs si está configurado
if [ "${datadog_enable_logs}" = "true" ]; then
    sudo sed -i 's/# logs_enabled: false/logs_enabled: true/' /etc/datadog-agent/datadog.yaml
fi

# Reiniciar y habilitar el agente
sudo systemctl restart datadog-agent
sudo systemctl enable datadog-agent

echo "Datadog agent configured for LTI Frontend"

# ==============================================================================
# DESPLIEGUE DE LA APLICACIÓN FRONTEND
# ==============================================================================

echo "Deploying LTI Frontend application..."

# Descargar y descomprimir el archivo frontend.zip desde S3
aws s3 cp s3://ai4devs-project-code-bucket/frontend.zip /home/ec2-user/frontend.zip
unzip /home/ec2-user/frontend.zip -d /home/ec2-user/

# Construir la imagen Docker para el frontend
cd /home/ec2-user/frontend
sudo docker build -t lti-frontend .

# Ejecutar el contenedor Docker con labels para Datadog
sudo docker run -d \
    --name lti-frontend-container \
    -p 3000:3000 \
    --label "com.datadoghq.tags.service=${monitor_frontend_service}" \
    --label "com.datadoghq.tags.env=${environment}" \
    --label "com.datadoghq.tags.project=${project_name}" \
    --restart unless-stopped \
    lti-frontend

echo "LTI Frontend deployed successfully with Datadog monitoring"

# Timestamp to force update
echo "Deployment completed at: $(date)"
echo "Timestamp: ${timestamp}"
