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

# Crear directorio para logs de aplicaciones LTI
sudo mkdir -p /var/log/lti/frontend
sudo chmod 755 /var/log/lti/frontend

# Habilitar logs si está configurado
if [ "${datadog_enable_logs}" = "true" ]; then
    sudo sed -i 's/# logs_enabled: false/logs_enabled: true/' /etc/datadog-agent/datadog.yaml
fi

# Configurar recolección de logs específicos para el frontend
sudo tee /etc/datadog-agent/conf.d/lti-frontend.yaml > /dev/null << EOF
# Configuración específica del frontend LTI
init_config:

instances:
  - name: lti-frontend

logs:
  # Logs del contenedor frontend
  - type: docker
    image: lti-frontend
    service: ${monitor_frontend_service}
    source: javascript
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:frontend"
      - "component:webapp"
      - "host:frontend-server"

  # Logs de archivos del frontend (si existen)
  - type: file
    path: "/var/log/lti/frontend/*.log"
    service: ${monitor_frontend_service}
    source: javascript
    sourcecategory: lti-frontend
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:frontend"
      - "component:webapp"
      - "host:frontend-server"

  # Logs de Docker para este contenedor
  - type: docker
    name: lti-frontend-container
    service: ${monitor_frontend_service}
    source: docker
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:frontend"
      - "component:webapp"

  # Logs de Nginx (si está presente)
  - type: file
    path: "/var/log/nginx/access.log"
    service: nginx
    source: nginx
    sourcecategory: http_web_access
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:frontend"
      - "component:webserver"

  - type: file
    path: "/var/log/nginx/error.log"
    service: nginx
    source: nginx
    sourcecategory: http_web_access
    tags:
      - "project:${project_name}"
      - "environment:${environment}"
      - "team:frontend"
      - "component:webserver"
EOF

# Reiniciar y habilitar el agente
sudo systemctl restart datadog-agent
sudo systemctl enable datadog-agent

echo "Datadog agent configured for LTI Frontend with logs"

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
    -p 80:3000 \
    -e REACT_APP_ENV=${environment} \
    -e REACT_APP_VERSION=1.0.0 \
    --label "com.datadoghq.tags.service=${monitor_frontend_service}" \
    --label "com.datadoghq.tags.env=${environment}" \
    --label "com.datadoghq.tags.project=${project_name}" \
    --label "com.datadoghq.tags.team=frontend" \
    --label "com.datadoghq.tags.component=webapp" \
    -v /var/log/lti/frontend:/var/log/app \
    --restart unless-stopped \
    lti-frontend

echo "LTI Frontend deployed successfully with Datadog monitoring and logs"

# Timestamp to force update
echo "Deployment completed at: $(date)"
echo "Timestamp: ${timestamp}"
