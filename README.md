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

```
cd backend
npm run build
```

4. Inicia el servidor backend:

```
cd backend
npm start
```

5. En una nueva ventana de terminal, construye el servidor frontend:

```
cd frontend
npm run build
```

6. Inicia el servidor frontend:

```
cd frontend
npm start
```

El servidor backend estará corriendo en http://localhost:3010 y el frontend estará disponible en http://localhost:3000.

## Docker y PostgreSQL

Este proyecto usa Docker para ejecutar una base de datos PostgreSQL. Así es cómo ponerlo en marcha:

Instala Docker en tu máquina si aún no lo has hecho. Puedes descargarlo desde aquí.
Navega al directorio raíz del proyecto en tu terminal.
Ejecuta el siguiente comando para iniciar el contenedor Docker:

```
docker-compose up -d
```

Esto iniciará una base de datos PostgreSQL en un contenedor Docker. La bandera -d corre el contenedor en modo separado, lo que significa que se ejecuta en segundo plano.

Para acceder a la base de datos PostgreSQL, puedes usar cualquier cliente PostgreSQL con los siguientes detalles de conexión:

- Host: localhost
- Port: 5432
- User: postgres
- Password: password
- Database: mydatabase

Por favor, reemplaza User, Password y Database con el usuario, la contraseña y el nombre de la base de datos reales especificados en tu archivo .env.

Para detener el contenedor Docker, ejecuta el siguiente comando:

```
docker-compose down
```

Para generar la base de datos utilizando Prisma, sigue estos pasos:

1. Asegúrate de que el archivo `.env` en el directorio raíz del backend contenga la variable `DATABASE_URL` con la cadena de conexión correcta a tu base de datos PostgreSQL. Si no te funciona, prueba a reemplazar la URL completa directamente en `schema.prisma`, en la variable `url`.

2. Abre una terminal y navega al directorio del backend donde se encuentra el archivo `schema.prisma` y `seed.ts`.

3. Ejecuta los siguientes comandos para generar la estructura de prisma, las migraciones a tu base de datos y poblarla con datos de ejemplo:

```
npx prisma generate
npx prisma migrate dev
ts-node seed.ts
```

Una vez has dado todos los pasos, deberías poder guardar nuevos candidatos, tanto via web, como via API, verlos en la base de datos y obtenerlos mediante GET por id.

```
POST http://localhost:3010/candidates
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

### Arquitectura de Monitorización

La solución de monitorización implementa:

- **Integración AWS-Datadog** para métricas de CloudWatch
- **Agentes Datadog** instalados en instancias EC2 (backend y frontend)
- **Dashboard personalizado** para visualización del Sistema LTI
- **Alertas configurables** basadas en umbrales específicos del proyecto
- **Recolección de logs** de aplicaciones Node.js y React

### Configuración de Datadog

#### Archivos de Configuración

1. **`tf/variables.tf`** - Variables principales para Datadog:

   - Credenciales de API (marcadas como sensibles)
   - Configuración del agente Datadog
   - Umbrales de monitorización específicos para LTI
   - Tags organizados por servicio (backend/frontend)

2. **`tf/terraform.tfvars.example`** - Plantilla de configuración segura:

   - Ejemplo de configuración de credenciales
   - Valores recomendados para el proyecto LTI
   - Documentación sobre dónde obtener API keys

3. **`.gitignore`** - Seguridad de credenciales:
   - Exclusión de archivos `terraform.tfvars` con credenciales reales
   - Protección de estados de Terraform sensibles

#### Características de Seguridad Implementadas

- **Variables Sensibles**: `datadog_api_key` y `datadog_app_key` marcadas como `sensitive = true`
- **Validaciones**: Verificación de que las API keys no estén vacías
- **Exclusiones Git**: Archivos con credenciales excluidos del control de versiones
- **External ID**: Configuración para role seguro AWS-Datadog

#### Variables Principales Configuradas

```hcl
# Credenciales (obligatorias)
datadog_api_key                # API Key de Datadog
datadog_app_key               # Application Key de Datadog

# Configuración del agente
datadog_agent_version         # Versión del agente (default: "latest")
datadog_enable_logs          # Habilitar logs (default: true)
datadog_enable_apm           # Habilitar APM (default: true)

# Umbrales de alerta para LTI
cpu_threshold_warning        # CPU warning (default: 70%)
cpu_threshold_critical       # CPU crítico (default: 85%)
memory_threshold_warning     # Memoria warning (default: 80%)
memory_threshold_critical    # Memoria crítico (default: 90%)

# Servicios monitoreados
monitor_backend_service      # Nombre servicio backend: "lti-backend"
monitor_frontend_service     # Nombre servicio frontend: "lti-frontend"
```

### Convenciones del Proyecto

- **Naming**: Mantiene convención `lti-project-*` para consistencia
- **Tagging**: Tags específicos para backend (`service:lti-backend`) y frontend (`service:lti-frontend`)
- **Estructura**: Código modular y documentado por funcionalidad

### Configuración Inicial Requerida

Antes de continuar con los siguientes pasos, necesitas:

1. **Obtener credenciales de Datadog**:

   ```bash
   # Visita: https://app.datadoghq.com/organization-settings/api-keys
   # Obtén: API Key y Application Key
   ```

2. **Configurar variables**:

   ```bash
   cd tf/
   cp terraform.tfvars.example terraform.tfvars
   # Editar terraform.tfvars con tus credenciales reales
   ```

3. **Verificar configuración**:
   ```bash
   terraform validate
   terraform plan
   ```

### Servicios AWS Monitoreados

- **EC2**: Métricas de instancias backend y frontend
- **CloudWatch**: Logs y métricas del sistema
- **S3**: Métricas del bucket de código
- **IAM**: Monitorización de roles y políticas

### ✅ Pasos Completados

#### Paso 1: Variables Terraform ✅

Se configuraron todas las variables necesarias en `tf/variables.tf` con validaciones de seguridad.

#### Paso 2: Proveedor Datadog ✅

Se configuró el proveedor de Datadog v3.40+ en `tf/provider.tf` con autenticación por API keys.

#### Paso 3: Integración AWS-Datadog ✅

Se implementó la integración completa en `tf/datadog.tf` incluyendo:

- **Política IAM**: Permisos para CloudWatch, EC2, S3, IAM (solo lectura)
- **Role IAM**: Role con External ID que Datadog puede asumir
- **Dashboard**: Panel de control con métricas de CPU y memoria
- **Outputs**: ARN del role, External ID y URLs para configuración manual

**Configuración Manual Requerida:**

1. En Datadog → Integrations → AWS → Add AWS Account
2. Usar Role ARN: `(output de terraform apply)`
3. Usar External ID: `(output de terraform apply)`
4. Account ID: `(output de terraform apply)`

### Próximos Pasos de Implementación

- [ ] **Paso 4**: Instalar agentes Datadog en instancias EC2
- [ ] **Paso 5**: Configurar logs y APM específicos del proyecto LTI
- [ ] **Paso 6**: Documentar configuración final y verificar monitorización

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

- Las API keys de Datadog son **OBLIGATORIAS** y deben configurarse antes de continuar
- El External ID debe ser único y compartido solo con Datadog
- Nunca commit archivos `terraform.tfvars` con credenciales reales

🔧 **Configuración**:

- Los umbrales de alerta pueden ajustarse según necesidades específicas del LTI
- La configuración actual soporta monitorización completa de la infraestructura AWS
- Tags específicos permiten filtrado granular en Datadog

📝 **Documentación**:

- Todos los cambios se documentan en `prompts/datadog-aws-prompts.md`
- Cada paso incluye verificación y validación
- Se mantiene historial de implementación para referencia futura
