#!/bin/bash

# ==============================================================================
# BACKEND USER DATA SCRIPT - LTI PROJECT CON DATADOG
# ==============================================================================

# Actualizar sistema e instalar dependencias básicas
yum update -y
sudo yum install -y docker curl

# Iniciar el servicio de Docker
sudo service docker start

# ==============================================================================
# INSTALACIÓN Y CONFIGURACIÓN DEL AGENTE DATADOG
# ==============================================================================

echo "Installing Datadog agent for LTI Backend..."

# Instalar el agente Datadog
DD_API_KEY="${datadog_api_key}" DD_SITE="${datadog_site}" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configurar tags básicos para el agente
sudo sed -i "s/# tags:/tags:\n  - project:${project_name}\n  - environment:${environment}\n  - service:${monitor_backend_service}\n  - role:backend/" /etc/datadog-agent/datadog.yaml

# Crear directorio para logs de aplicaciones LTI
sudo mkdir -p /var/log/lti/backend
sudo chmod 755 /var/log/lti/backend

# Habilitar logs si está configurado
if [ "${datadog_enable_logs}" = "true" ]; then
    sudo sed -i 's/# logs_enabled: false/logs_enabled: true/' /etc/datadog-agent/datadog.yaml
fi

# Habilitar APM si está configurado
if [ "${datadog_enable_apm}" = "true" ]; then
    sudo tee -a /etc/datadog-agent/datadog.yaml > /dev/null <<EOF

# Configuración APM para backend LTI
apm_config:
  enabled: true
  apm_dd_url: https://trace.agent.${datadog_site}
  receiver_port: 8126
EOF
fi

# Configurar recolección de logs específicos para el backend
sudo tee /etc/datadog-agent/conf.d/lti-backend.yaml > /dev/null <<EOF
# Configuración específica del backend LTI
init_config:

instances:
  - name: lti-backend

logs:
  # Logs del contenedor backend
  - type: docker
    image: lti-backend
    service: ${monitor_backend_service}
    source: nodejs
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:backend"
      - "component:api"
      - "host:backend-server"

  # Logs de archivos del backend (si existen)
  - type: file
    path: "/var/log/lti/backend/*.log"
    service: ${monitor_backend_service}
    source: nodejs
    sourcecategory: lti-backend
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:backend"
      - "component:api"
      - "host:backend-server"

  # Logs de Docker para este contenedor
  - type: docker
    name: lti-backend-container
    service: ${monitor_backend_service}
    source: docker
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:backend"
      - "component:api"
EOF

# Reiniciar y habilitar el agente
sudo systemctl restart datadog-agent
sudo systemctl enable datadog-agent

echo "Datadog agent configured for LTI Backend with logs and APM"

# ==============================================================================
# DESPLIEGUE DE LA APLICACIÓN BACKEND
# ==============================================================================

echo "Deploying LTI Backend application..."

# Descargar y descomprimir el archivo backend.zip desde S3
aws s3 cp s3://ai4devs-project-code-bucket/backend.zip /home/ec2-user/backend.zip
unzip /home/ec2-user/backend.zip -d /home/ec2-user/

# Construir la imagen Docker para el backend
cd /home/ec2-user/backend
sudo docker build -t lti-backend .

# Ejecutar el contenedor Docker con labels para Datadog y configuración APM
sudo docker run -d \
    --name lti-backend-container \
    -p 8080:8080 \
    -e DD_TRACE_AGENT_URL=unix:///var/run/datadog/apm.socket \
    -e DD_SERVICE=${monitor_backend_service} \
    -e DD_ENV=${environment} \
    -e DD_VERSION=1.0.0 \
    -e DD_TAGS="project:${project_name},team:backend,component:api" \
    --label "com.datadoghq.tags.service=${monitor_backend_service}" \
    --label "com.datadoghq.tags.env=${environment}" \
    --label "com.datadoghq.tags.project=${project_name}" \
    --label "com.datadoghq.tags.team=backend" \
    --label "com.datadoghq.tags.component=api" \
    -v /var/run/datadog:/var/run/datadog \
    -v /var/log/lti/backend:/var/log/app \
    --restart unless-stopped \
    lti-backend

echo "LTI Backend deployed successfully with Datadog monitoring, logs and APM"

# Timestamp to force update
echo "Deployment completed at: $(date)"
echo "Timestamp: ${timestamp}"
