# LTI - Sistema de Seguimiento de Talento

Este proyecto es una aplicación full-stack con un frontend en React y un backend en Express usando Prisma como un ORM. El frontend se inicia con Create React App y el backend está escrito en TypeScript.

## Explicación de Directorios y Archivos

- `backend/`: Contiene el código del lado del servidor escrito en Node.js.
  - `src/`: Contiene el código fuente para el backend.
    - `index.ts`: El punto de entrada para el servidor backend.
    - `application/`: Contiene la lógica de aplicación.
    - `domain/`: Contiene la lógica de negocio.
    - `infrastructure/`: Contiene código que se comunica con la base de datos.
    - `presentation/`: Contiene código relacionado con la capa de presentación (como controladores).
    - `routes/`: Contiene las definiciones de rutas para la API.
    - `tests/`: Contiene archivos de prueba.
  - `prisma/`: Contiene el archivo de esquema de Prisma para ORM.
  - `tsconfig.json`: Archivo de configuración de TypeScript.
- `frontend/`: Contiene el código del lado del cliente escrito en React.
  - `src/`: Contiene el código fuente para el frontend.
  - `public/`: Contiene archivos estáticos como el archivo HTML e imágenes.
  - `build/`: Contiene la construcción lista para producción del frontend.
- `tf/`: Contiene la infraestructura como código usando Terraform.
  - `variables.tf`: Variables de configuración para Terraform y Datadog.
  - `provider.tf`: Configuración de proveedores (AWS, Datadog).
  - `ec2.tf`: Configuración de instancias EC2.
  - `datadog.tf`: Configuración de monitorización con Datadog.
  - `scripts/`: Scripts de inicialización para instancias EC2.
- `.env`: Contiene las variables de entorno.
- `docker-compose.yml`: Contiene la configuración de Docker Compose para gestionar los servicios de tu aplicación.
- `README.md`: Este archivo, contiene información sobre el proyecto e instrucciones sobre cómo ejecutarlo.

## Estructura del Proyecto

El proyecto está dividido en dos directorios principales: `frontend` y `backend`.

### Frontend

El frontend es una aplicación React y sus archivos principales están ubicados en el directorio `src`. El directorio `public` contiene activos estáticos y el directorio `build` contiene la construcción de producción de la aplicación.

### Backend

El backend es una aplicación Express escrita en TypeScript. El directorio `src` contiene el código fuente, dividido en varios subdirectorios:

- `application`: Contiene la lógica de aplicación.
- `domain`: Contiene los modelos de dominio.
- `infrastructure`: Contiene código relacionado con la infraestructura.
- `presentation`: Contiene código relacionado con la capa de presentación.
- `routes`: Contiene las rutas de la aplicación.
- `tests`: Contiene las pruebas de la aplicación.

El directorio `prisma` contiene el esquema de Prisma.

Tienes más información sobre buenas prácticas utilizadas en la [guía de buenas prácticas](./backend/ManifestoBuenasPracticas.md).

Las especificaciones de todos los endpoints de API los tienes en [api-spec.yaml](./backend/api-spec.yaml).

La descripción y diagrama del modelo de datos los tienes en [ModeloDatos.md](./backend/ModeloDatos.md).

## Primeros Pasos

Para comenzar con este proyecto, sigue estos pasos:

1. Clona el repositorio.
2. Instala las dependencias para el frontend y el backend:

```sh
cd frontend
npm install

cd ../backend
npm install
```

3. Construye el servidor backend:

```sh
cd backend
npm run build
```

4. Inicia el servidor backend:

```sh
cd backend
npm start
```

5. En una nueva ventana de terminal, construye el servidor frontend:

```sh
cd frontend
npm run build
```

6. Inicia el servidor frontend:

```sh
cd frontend
npm start
```

El servidor backend estará corriendo en `http://localhost:3010` y el frontend estará disponible en `http://localhost:3000`.

## Docker y PostgreSQL

Este proyecto usa Docker para ejecutar una base de datos PostgreSQL. Así es cómo ponerlo en marcha:

1. Instala Docker en tu máquina si aún no lo has hecho. Puedes descargarlo desde [aquí](https://www.docker.com/get-started).
2. Navega al directorio raíz del proyecto en tu terminal.
3. Ejecuta el siguiente comando para iniciar el contenedor Docker:

```sh
docker-compose up -d
```

Esto iniciará una base de datos PostgreSQL en un contenedor Docker. La bandera `-d` corre el contenedor en modo separado, lo que significa que se ejecuta en segundo plano.

Para acceder a la base de datos PostgreSQL, puedes usar cualquier cliente PostgreSQL con los siguientes detalles de conexión:

- **Host**: `localhost`
- **Port**: `5432`
- **User**: `postgres`
- **Password**: `password`
- **Database**: `mydatabase`

**Nota**: Por favor, reemplaza `User`, `Password` y `Database` con el usuario, la contraseña y el nombre de la base de datos reales especificados en tu archivo `.env`.

Para detener el contenedor Docker, ejecuta el siguiente comando:

```sh
docker-compose down
```

Para generar la base de datos utilizando Prisma, sigue estos pasos:

1. Asegúrate de que el archivo `.env` en el directorio raíz del backend contenga la variable `DATABASE_URL` con la cadena de conexión correcta a tu base de datos PostgreSQL. Si no te funciona, prueba a reemplazar la URL completa directamente en `schema.prisma`, en la variable `url`.
2. Abre una terminal y navega al directorio del backend donde se encuentra el archivo `schema.prisma` y `seed.ts`.
3. Ejecuta los siguientes comandos para generar la estructura de prisma, las migraciones a tu base de datos y poblarla con datos de ejemplo:

```sh
npx prisma generate
npx prisma migrate dev
ts-node seed.ts
```

Una vez has dado todos los pasos, deberías poder guardar nuevos candidatos, tanto via web, como via API, verlos en la base de datos y obtenerlos mediante GET por id.

**Ejemplo de Petición POST para crear un candidato**:

```http
POST http://localhost:3010/candidates
Content-Type: application/json

{
    "firstName": "Albert",
    "lastName": "Saelices",
    "email": "albert.saelices@gmail.com",
    "phone": "656874937",
    "address": "Calle Sant Dalmir 2, 5ºB. Barcelona",
    "educations": [
        {
            "institution": "UC3M",
            "title": "Computer Science",
            "startDate": "2006-12-31",
            "endDate": "2010-12-26"
        }
    ],
    "workExperiences": [
        {
            "company": "Coca Cola",
            "position": "SWE",
            "description": "",
            "startDate": "2011-01-13",
            "endDate": "2013-01-17"
        }
    ],
    "cv": {
        "filePath": "uploads/1715760936750-cv.pdf",
        "fileType": "application/pdf"
    }
}
```

---

## 📊 Monitorización con Datadog

Este proyecto incluye integración completa con Datadog para monitorización de infraestructura y aplicaciones desplegadas en AWS usando Terraform.

### ✅ Estado de Implementación

- **Paso 1 ✅**: Configuración de Variables Terraform para Datadog
- **Paso 2 ✅**: Configuración del Proveedor Datadog
- **Paso 3 ✅**: Integración AWS-Datadog (Roles IAM, Políticas, Dashboard)
- **Paso 4 ✅**: Instalación de Agentes Datadog en Instancias EC2
- **Paso 5 ✅**: Configuración de Logs y APM específicos del proyecto LTI

### Arquitectura de Monitorización

La solución de monitorización implementa:

- **Integración AWS-Datadog** para métricas de CloudWatch.
- **Agentes Datadog** instalados en instancias EC2 (backend y frontend).
- **Dashboard personalizado** para visualización del Sistema LTI.
- **Alertas configurables** basadas en umbrales específicos del proyecto.
- **Recolección de logs** de aplicaciones Node.js y React.

### Configuración de Datadog

#### Archivos de Configuración

1.  **`tf/variables.tf`** - Variables principales para Datadog:

    - Credenciales de API (marcadas como sensibles)
    - Configuración del agente Datadog
    - Umbrales de monitorización específicos para LTI
    - Tags organizados por servicio (backend/frontend)

2.  **`tf/terraform.tfvars.example`** - Plantilla de configuración segura:

    - Ejemplo de configuración de credenciales
    - Valores recomendados para el proyecto LTI
    - Documentación sobre dónde obtener API keys

3.  **`.gitignore`** - Seguridad de credenciales:
    - Exclusión de archivos `terraform.tfvars` con credenciales reales
    - Protección de estados de Terraform sensibles

#### Características de Seguridad Implementadas

- **Variables Sensibles**: `datadog_api_key` y `datadog_app_key` marcadas como `sensitive = true`.
- **Validaciones**: Verificación de que las API keys no estén vacías.
- **Exclusiones Git**: Archivos con credenciales excluidos del control de versiones.
- **External ID**: Configuración para role seguro AWS-Datadog.

#### Variables Principales Configuradas

```hcl
# Credenciales (obligatorias)
variable "datadog_api_key" { ... }
variable "datadog_app_key" { ... }

# Configuración del agente
variable "datadog_agent_version" { ... }        # Versión del agente (default: "latest")
variable "datadog_enable_logs" { ... }         # Habilitar logs (default: true)
variable "datadog_enable_apm" { ... }          # Habilitar APM (default: true)

# Umbrales de alerta para LTI
variable "cpu_threshold_warning" { ... }       # CPU warning (default: 70%)
variable "cpu_threshold_critical" { ... }      # CPU crítico (default: 85%)
variable "memory_threshold_warning" { ... }    # Memoria warning (default: 80%)
variable "memory_threshold_critical" { ... }   # Memoria crítico (default: 90%)

# Servicios monitoreados
variable "monitor_backend_service" { ... }     # Nombre servicio backend: "lti-backend"
variable "monitor_frontend_service" { ... }    # Nombre servicio frontend: "lti-frontend"
```

### Convenciones del Proyecto

- **Naming**: Mantiene convención `lti-project-*` para consistencia.
- **Tagging**: Tags específicos para backend (`service:lti-backend`) y frontend (`service:lti-frontend`).
- **Estructura**: Código modular y documentado por funcionalidad.

### Configuración Inicial Requerida

Antes de continuar con los siguientes pasos, necesitas:

1.  **Obtener credenciales de Datadog**:

    - Visita: [Datadog API Keys](https://app.datadoghq.com/organization-settings/api-keys)
    - Obtén: API Key y Application Key

2.  **Configurar variables**:

    ```bash
    cd tf/
    cp terraform.tfvars.example terraform.tfvars
    # Edita terraform.tfvars con tus credenciales reales
    ```

3.  **Verificar configuración**:

    ```bash
    cd tf/
    terraform validate
    terraform plan
    ```

### Servicios AWS Monitoreados

- **EC2**: Métricas de instancias backend y frontend.
- **CloudWatch**: Logs y métricas del sistema.
- **S3**: Métricas del bucket de código.
- **IAM**: Monitorización de roles y políticas.

### ✅ Pasos Completados

#### Paso 1: Variables Terraform ✅

Se configuraron todas las variables necesarias en `tf/variables.tf` con validaciones de seguridad.

#### Paso 2: Proveedor Datadog ✅

Se configuró el proveedor de Datadog v3.40+ en `tf/provider.tf` con autenticación por API keys.

#### Paso 3: Integración AWS-Datadog ✅

Se implementó la integración completa en `tf/datadog.tf` incluyendo:

- **Política IAM**: Permisos para CloudWatch, EC2, S3, IAM (solo lectura).
- **Role IAM**: Role con External ID que Datadog puede asumir.
- **Dashboard**: Panel de control con métricas de CPU y memoria.
- **Outputs**: ARN del role, External ID y URLs para configuración manual.

**Configuración Manual Requerida:**

1.  En Datadog → Integrations → AWS → Add AWS Account.
2.  Usar Role ARN: `(output de terraform apply)`.
3.  Usar External ID: `(output de terraform apply)`.
4.  Account ID: `(output de terraform apply)`.

#### Paso 4: Instalación de Agentes Datadog ✅

Se configuró la instalación automática de agentes Datadog en ambas instancias EC2:

- **Scripts Modificados**:
  - `tf/scripts/backend_user_data.sh` - Instalación para servidor backend.
  - `tf/scripts/frontend_user_data.sh` - Instalación para servidor frontend.
- **Configuración de Agentes**: Tags específicos por servicio (backend/frontend).
- **Integración Docker**: Labels para contenedores con identificación de Datadog.
- **Variables EC2**: Todas las credenciales y configuraciones pasadas via `templatefile`.

**Características Implementadas en Paso 4:**

- Instalación automática del agente al lanzar instancias.
- Tags específicos por rol (backend/frontend).
- Habilitación de logs si está configurado.
- Labels de Docker para mejor identificación en Datadog.
- Reinicio automático de contenedores con `--restart unless-stopped`.

#### Paso 5: Configuración de Logs y APM ✅

Se implementó la configuración automática de logs y APM sin modificar el código de las aplicaciones:

**Configuración de Logs Automática:**

- **Logs de contenedores Docker**: Recolección automática de logs de contenedores `lti-backend` y `lti-frontend`.
- **Logs de archivos**: Configuración para logs en `/var/log/lti/backend/` y `/var/log/lti/frontend/`.
- **Logs del sistema**: Monitoreo de Docker y Nginx (si está presente).
- **Tags específicos**: Cada log incluye tags de proyecto, ambiente, equipo y componente.

**Configuración de APM para Backend:**

- **APM automático**: Habilitado en el agente Datadog para el backend Node.js/Express.
- **Variables de entorno**: Configuración automática de `DD_SERVICE`, `DD_ENV`, `DD_VERSION`.
- **Socket Unix**: Comunicación eficiente entre aplicación y agente via socket.
- **Sin cambios de código**: APM funciona automáticamente sin modificar la aplicación.

**Archivos Configurados en Paso 5:**

- `tf/scripts/backend_user_data.sh` - Configuración completa de logs y APM para backend.
- `tf/scripts/frontend_user_data.sh` - Configuración de logs para frontend.
- `tf/scripts/datadog_agent_config.yaml` - Configuración base del agente.
- `tf/datadog.tf` - Dashboard actualizado con widgets de logs.

**Características Implementadas en Paso 5:**

- Directorios de logs creados automáticamente (`/var/log/lti/backend`, `/var/log/lti/frontend`).
- Configuración específica por servicio en `/etc/datadog-agent/conf.d/`.
- Labels de Docker para identificación automática en Datadog.
- Variables de entorno para APM configuradas en contenedores.
- Reinicio automático de agente después de configuración.

#### Paso 6: Documentación Final y Verificación ✅

**Configuración de Credenciales AWS Completada:**

La configuración está lista para despliegue. Asegúrate de tener configuradas las variables de entorno de AWS en tu terminal:

```powershell
$Env:AWS_ACCESS_KEY_ID = "tu_access_key_id"
$Env:AWS_SECRET_ACCESS_KEY = "tu_secret_access_key"
$Env:AWS_DEFAULT_REGION = "us-east-1"  # O tu región preferida
```

### 🚀 Despliegue de la Infraestructura

#### Pasos para Desplegar

1. **Configurar Credenciales de Datadog**:

   ```bash
   cd tf/
   cp terraform.tfvars.example terraform.tfvars
   # Edita terraform.tfvars con tus API keys de Datadog
   ```

2. **Verificar Configuración**:

   ```bash
   terraform validate
   terraform plan
   ```

3. **Desplegar Infraestructura**:
   ```bash
   terraform apply
   # Escribe 'yes' cuando se te solicite confirmación
   ```

#### Outputs Importantes de Terraform

Una vez ejecutado `terraform apply`, obtendrás los siguientes outputs importantes:

- **`datadog_role_arn`**: ARN del rol IAM que Datadog utilizará
- **`datadog_external_id`**: ID externo para la integración segura
- **`datadog_dashboard_url`**: URL directa al dashboard principal del sistema LTI
- **`aws_account_id`**: ID de tu cuenta AWS para configuración en Datadog

### 🔍 Verificación Post-Despliegue

#### 1. Verificar Integración AWS-Datadog

**En la Consola de Datadog:**

1. Ve a **Integrations** → **AWS**
2. Haz clic en **Add AWS Account**
3. Configura manualmente la integración usando los outputs de Terraform:
   - **Role ARN**: Usa el valor de `datadog_role_arn`
   - **External ID**: Usa el valor de `datadog_external_id`
   - **Account ID**: Usa el valor de `aws_account_id`
4. Selecciona los servicios a monitorear: EC2, CloudWatch, S3, IAM

#### 2. Verificar Instancias EC2 y Agentes

**En Datadog → Infrastructure → Host Map:**

- ✅ Deberías ver 2 hosts:
  - `lti-project-backend` (tags: `service:lti-backend`, `role:backend`)
  - `lti-project-frontend` (tags: `service:lti-frontend`, `role:frontend`)
- ✅ Ambos hosts deben aparecer como **activos** (verde)
- ✅ Cada host debe mostrar métricas de sistema (CPU, memoria, disco)

**Comando de Diagnóstico en Instancias EC2** (si tienes acceso SSH):

```bash
sudo datadog-agent status
# Debe mostrar: "Agent (v7.x.x)" y estado "OK"
```

#### 3. Verificar Métricas y Dashboard

**En el Dashboard Principal:**

1. Ve a la URL proporcionada en `datadog_dashboard_url`
2. O navega a **Dashboards** y busca **"LTI - Sistema de Seguimiento de Talento"**

**Widgets que debes verificar:**

- ✅ **CPU Utilization**: Gráficos con datos de ambas instancias
- ✅ **Memory Utilization**: Métricas de memoria de backend y frontend
- ✅ **Service Status**: Widgets mostrando estado UP de los servicios
- ✅ **Logs Stream**: Logs recientes de aplicaciones y sistema

#### 4. Verificar Logs

**En Datadog → Logs → Explorer:**

- ✅ Filtra por `service:lti-backend` - Deberías ver:
  - Logs del contenedor Docker `lti-backend`
  - Logs del agente Datadog
  - Logs del sistema de la instancia backend
- ✅ Filtra por `service:lti-frontend` - Deberías ver:
  - Logs del contenedor Docker `lti-frontend`
  - Logs del agente Datadog
  - Logs del sistema de la instancia frontend
- ✅ Filtra por `project:lti-talent-tracking` - Todos los logs del proyecto

#### 5. Verificar APM (Application Performance Monitoring)

**En Datadog → APM → Services:**

- ✅ Deberías ver el servicio `lti-backend` listado
- ✅ Al hacer clic en el servicio, deberías ver:
  - Trazas de peticiones HTTP
  - Métricas de latencia y throughput
  - Endpoints de la API
  - Errores si los hay

**Para generar trazas**: Una vez desplegada la aplicación, realiza peticiones a los endpoints:

```bash
# Ejemplo de petición para generar trazas
curl http://[IP-PUBLICA-BACKEND]:8080/
curl http://[IP-PUBLICA-FRONTEND]/
```

#### 6. Verificar Alertas y Monitores

**En Datadog → Monitors → Manage Monitors:**

- ✅ **"LTI - CPU crítico en instancias"**: Monitor configurado con umbrales
- ✅ **"LTI - Memoria crítica en instancias"**: Monitor de memoria
- ✅ Ambos monitores deben estar en estado **OK** si el sistema funciona correctamente

### 🔧 Troubleshooting Común

#### Si las instancias no aparecen en Datadog:

1. **Verificar Security Groups**: Asegúrate de que el puerto 443 (HTTPS) está abierto hacia Internet para que el agente pueda comunicarse con Datadog
2. **Verificar API Keys**: Confirma que `datadog_api_key` en `terraform.tfvars` es correcta
3. **Verificar User Data**: Los logs de User Data se encuentran en `/var/log/cloud-init-output.log` en las instancias EC2

#### Si no llegan logs:

1. **Verificar permisos**: El agente Datadog debe tener permisos de lectura en los directorios de logs
2. **Verificar configuración**: Revisa `/etc/datadog-agent/conf.d/lti-*.yaml` en las instancias
3. **Reiniciar agente**: `sudo systemctl restart datadog-agent`

#### Si APM no funciona:

1. **Verificar variables de entorno**: Las variables `DD_*` deben estar configuradas en los contenedores
2. **Verificar socket Unix**: El path `/var/run/datadog/apm.socket` debe ser accesible
3. **Verificar puerto APM**: El puerto 8126 debe estar abierto para trazas

### 📋 Checklist Final de Verificación

- [ ] Credenciales AWS configuradas y `terraform apply` ejecutado exitosamente
- [ ] Integración AWS-Datadog configurada manualmente en consola
- [ ] 2 instancias EC2 visibles en Host Map de Datadog
- [ ] Dashboard "LTI - Sistema de Seguimiento de Talento" muestra datos
- [ ] Logs visibles en Log Explorer con tags correctos
- [ ] Servicio `lti-backend` visible en APM después de generar tráfico
- [ ] Monitores de CPU y memoria configurados y funcionando
- [ ] Aplicaciones accesibles desde Internet y funcionando

### ✅ Estado Final de Implementación

**¡Implementación de Monitorización Datadog Completada!**

- ✅ **Paso 1**: Configuración de Variables Terraform para Datadog
- ✅ **Paso 2**: Configuración del Proveedor Datadog
- ✅ **Paso 3**: Integración AWS-Datadog (Roles IAM, Políticas, Dashboard)
- ✅ **Paso 4**: Instalación de Agentes Datadog en Instancias EC2
- ✅ **Paso 5**: Configuración de Logs y APM específicos del proyecto LTI
- ✅ **Paso 6**: Documentación Final y Verificación de Monitorización

**🎉 El Sistema de Seguimiento de Talento (LTI) ahora cuenta con monitorización completa con Datadog, incluyendo:**

- 📊 **Métricas de infraestructura** (CPU, memoria, disco, red)
- 📝 **Logs centralizados** de aplicaciones y sistema
- 🔍 **APM y trazas** de la aplicación backend Node.js
- 🚨 **Alertas configurables** basadas en umbrales
- 📈 **Dashboard personalizado** para visualización integral
- 🏷️ **Tags organizados** para fácil filtrado y gestión

La configuración es completamente automatizada via Terraform y no requiere modificaciones en el código de las aplicaciones.

### Comandos Útiles

```bash
# Validar configuración de Terraform
cd tf/
terraform validate

# Ver plan de despliegue
terraform plan

# Aplicar cambios (cuando esté listo)
terraform apply

# Ver estado actual
terraform show
```

### Notas Importantes

⚠️ **Seguridad**:

- Las API keys de Datadog son **OBLIGATORIAS** y deben configurarse antes de continuar.
- El External ID debe ser único y compartido solo con Datadog.
- Nunca commit archivos `terraform.tfvars` con credenciales reales.

🔧 **Configuración**:

- Los umbrales de alerta pueden ajustarse según necesidades específicas del LTI.
- La configuración actual soporta monitorización completa de la infraestructura AWS.
- Tags específicos permiten filtrado granular en Datadog.

📝 **Documentación**:

- Todos los cambios se documentan en `README.md` (este archivo).
- Cada paso incluye verificación y validación.
- Se mantiene historial de implementación para referencia futura.
