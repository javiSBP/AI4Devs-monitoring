# Meta-prompt inicial (Claude-4 en Cursor)

Crea un prompt para usarse como prompt de Cursor para realizar el siguiente ejercicios:

```md
En este ejercicio, ampliaremos nuestro proyecto de infraestructura como código utilizando Terraform para implementar un canal de monitorización de Datadog en AWS. Aprovecharemos técnicas de prompt engineering para automatizar la generación de código, lo que nos permitirá monitorear y obtener insights valiosos de nuestra infraestructura AWS de manera automatizada.

0️⃣ **Pre-requisitos:**

- Cuenta AWS (capa gratuita)
- Terraform instalado en tu equipo local
- Cuenta Datadog (puedes usar la prueba gratuita)
- Repositorio del ejercicio (código Terraform base del ejercicio anterior) el codigo de la clase anterior esta en este repositorio:
  🔗 https://github.com/LIDR-academy/AI4Devs-monitoring

1️⃣ **Configuración Inicial: **

- Asegúrate de tener configuradas tus credenciales de AWS y Datadog en tu entorno local.
- Revisa el código Terraform generado en el ejercicio anterior.
- Familiarízate con las técnicas de prompt engineering para la generación de código automatizado.
  2️⃣ **Objetivo del Ejercicio: **
  Tu misión es extender el código Terraform existente para:

Configurar la integración de Datadog con AWS usando Terraform.
Instalar el agente Datadog en la instancia EC2.
Crear un dashboard en Datadog para visualizar métricas clave de AWS.
3️⃣ **Pasos a Seguir:**
a) Configurar la Integración AWS-Datadog:
Utiliza Terraform para configurar la integración entre AWS y Datadog, siguiendo la guía proporcionada.
b) Configurar el Proveedor Datadog:
Añade el proveedor Datadog a tu configuración de Terraform.
c) Instalar el Agente Datadog:
Modifica el script de usuario de la instancia EC2 para instalar y configurar el agente Datadog.
d) Crear un Dashboard:
Utiliza Terraform para definir un dashboard en Datadog que muestre métricas relevantes de tu infraestructura AWS.
4️⃣ **Entrega:**
Crea una nueva rama en tu repositorio con tus iniciales
Actualiza los archivos Terraform existentes y añade nuevos según sea necesario.
Incluye un archivo README.md con:

- Explicación de los cambios realizados.
- Capturas de pantalla del dashboard y la alerta en Datadog.
- Documentación de los prompts utilizados en datadog-aws-prompts.md.
- Cualquier desafío encontrado y cómo lo resolviste.
  Crea un Pull Request con tus cambios.
  Recuerda que la lógica declarativa es muy sensible a cualquier información que le provees, asi que un gran prompt con muchos detalles podría hacer la diferencia para ti
  5️⃣ **Documentación:**
  En la carpeta prompts, crea un archivo 🔗datadog-aws-prompts.md donde documentes los prompts utilizados para generar el código Terraform relacionado con la integración Datadog-AWS.

📝 **Notas:**
Asegúrate de no compartir información sensible como claves API en tu código.

💡 **Recursos Útiles**:

- [Documentación de Terraform para Datadog](https://registry.terraform.io/providers/DataDog/datadog/latest/docs)
- [Guía de inicio rápido de Datadog para AWS](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=allpermissions)
- [Gestionando Datadog con Terraform](https://www.datadoghq.com/blog/managing-datadog-with-terraform/#deploy-datadog-with-terraform-today)
- [Configuración de AWS-Datadog con Terraform](https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/)
```

- Utiliza el contexto del proyecto para poner @el_fichero_a_leer_o_editar en el prompt
- Haz que el prompt indique que se vaya paso a paso y que vaya documentando en los ficheros como se indica
- Dame el prompt de salida en formato markdown que pueda copiar

# Prompt obtenido de Claude-4 y refinado por mí, para Integración Datadog-AWS con Terraform en proyecto LTI (Claude-4 en Cursor)

Soy el ingeniero responsable de extender la infraestructura del **Sistema de Seguimiento de Talento (LTI)** para implementar monitorización con Datadog en AWS usando Terraform. El proyecto actual tiene un backend en Node.js/Express con Prisma y un frontend en React, desplegados en instancias EC2.

## Contexto del Proyecto Actual

El proyecto LTI (@README.md) ya tiene infraestructura Terraform desplegada con:

- Instancias EC2 para backend y frontend (@tf/ec2.tf)
- Configuración de seguridad (@tf/security_groups.tf)
- Bucket S3 para código (@tf/s3.tf)
- Roles IAM (@tf/iam.tf)
- Scripts de user data (@tf/scripts/backend_user_data.sh, @tf/scripts/frontend_user_data.sh)

## Objetivo

Implementar monitorización completa con Datadog siguiendo estos pasos:

### 1. Configurar Proveedor Datadog

- Extender @tf/provider.tf para incluir el proveedor de Datadog
- Configurar variables necesarias en @tf/variables.tf para API keys de Datadog
- Asegurar que las credenciales no se hardcodeen

### 2. Configurar Integración AWS-Datadog

- Crear nuevo archivo @tf/datadog.tf con:
  - Recurso `datadog_integration_aws` para la integración
  - Política IAM necesaria para que Datadog acceda a AWS CloudWatch
  - Role IAM con las políticas requeridas para Datadog

### 3. Instalar Agente Datadog en EC2

- Modificar @tf/scripts/backend_user_data.sh para instalar agente Datadog
- Modificar @tf/scripts/frontend_user_data.sh para instalar agente Datadog
- Configurar el agente con las métricas apropiadas para cada servicio

### 4. Crear Dashboard Datadog

- En @tf/datadog.tf, añadir recurso `datadog_dashboard` con:
  - Métricas de sistema (CPU, memoria, disco) de las instancias EC2
  - Métricas de aplicación específicas del backend LTI
  - Métricas de red y acceso al frontend
  - Logs de aplicación si es posible

### 5. Documentación

- Añadir la documentación al fichero @README.md
- Explicación de los cambios realizados
- Documentar desafíos encontrados y soluciones

## Requisitos Específicos

1. **Seguridad**: Nunca hardcodear API keys - usar variables de Terraform
2. **Modularidad**: Mantener código organizado en archivos separados
3. **Compatibilidad**: Asegurar que funcione con la infraestructura existente
4. **Naming**: Seguir convención `lti-project-*` para recursos
5. **Tagging**: Aplicar tags consistentes con proyecto LTI

## Pasos de Implementación

**Ve paso a paso**, implementando y documentando cada sección antes de continuar:

1. Primero, actualiza @tf/variables.tf con variables para Datadog
2. Luego, extiende @tf/provider.tf con proveedor Datadog
3. Crea @tf/datadog.tf con integración AWS-Datadog
4. Modifica scripts de user data para instalar agente
5. Añade dashboard y alertas en Datadog
6. Documenta todo en @prompts/datadog-aws-prompts.md

## Resultado Esperado

Al finalizar debe ser posible:

- Ver métricas de las instancias EC2 del proyecto LTI en Datadog
- Monitorear la salud del backend y frontend
- Recibir alertas sobre problemas de infraestructura
- Tener visibilidad completa del sistema de seguimiento de talento

**¿Puedes empezar por el paso 1, actualizando las variables de Terraform para incluir las configuraciones de Datadog necesarias?**

# Paso 2

Vamos con el paso 2

# Pregunto por las api keys de DD

necesito usar datadog_app_key o con datadog_api_key sería suficiente?

# Terraform validate

necesito usar datafog_app_key o con datadog_api_key sería suficiente?
