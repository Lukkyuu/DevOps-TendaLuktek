# DevOps-TendaLuktek (Migración a AWS ECS Fargate)

Proyecto Semestral de DevOps 2026. Guía completa de arquitectura, infraestructura como código (Terraform), secretos de CI/CD, flujo de despliegue y configuración de Autoscaling.

---

## 🏗️ Arquitectura del Proyecto (AWS ECS Fargate)

El proyecto ha sido migrado desde un despliegue monolítico en EC2 hacia una arquitectura escalable de contenedores administrados en **AWS Elastic Container Service (ECS)** usando **Fargate**.

### Componentes de la Arquitectura Final:
- **Application Load Balancer (ALB)**: Expone el Frontend al público en el puerto 80 y balancea la carga entre las tareas.
- **ECS Cluster (Fargate)**: Clúster `tienda-cluster` ejecutando las aplicaciones de forma serverless.
- **Service Discovery (Cloud Map)**: Permite la resolución DNS interna para la comunicación Front -> Back.
  - El backend de ventas está en `ventas.tienda.local:8080`.
  - El backend de despachos está en `despachos.tienda.local:8081`.
- **Autoescalado (Target Tracking)**: Configurado en ECS para escalar horizontalmente las tareas (de 1 a 4 réplicas) en caso de que el uso de CPU promedio supere el 50%.
- **VPC & Subnets Públicas**: Los contenedores Fargate usan subredes públicas por simplicidad y reducción de costos (sin NAT Gateway), pero se protegen tras Security Groups.

| Capa / Componente | Puerto | Contenedor ECS | Notas Técnicas |
| :--- | :--- | :--- | :--- |
| **Base de Datos** | `3306` | - | Manteniendo la base de datos externa / EC2. Su IP se inyecta por variables de entorno en Terraform. |
| **Backend Ventas** | `8080` | `ventas-backend` | Fargate. Depende de las variables de entorno de BD (`DB_ENDPOINT`, etc.). |
| **Backend Despachos**| `8081` | `despachos-backend` | Fargate. Depende de las variables de entorno de BD. |
| **Frontend** | `80` | `frontend` | Servidor Nginx detrás del ALB. Proxy interno a los Backends. |

> [!NOTE]
> **Estructura en el repositorio**: El nuevo código de infraestructura (IaC) reside en `terraform/` y los flujos automatizados de despliegue a ECS residen en `.github/workflows/`.

---

## ⚙️ Configuración e Infraestructura como Código (Terraform)

Para levantar el entorno completo desde cero, utiliza los archivos que se encuentran en el directorio `terraform/`.

1. **Configurar Credenciales Localmente** (para ejecutar Terraform):
   Asegúrate de configurar tus credenciales de AWS en tu terminal local antes de ejecutar terraform (usando `aws configure` o variables de entorno).

2. **Aplicar los Cambios**:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

   > [!IMPORTANT]
   > Puedes modificar la dirección IP de tu Base de Datos en el archivo `terraform/variables.tf` (variable `db_host`) antes de aplicar para que los contenedores puedan conectarse a tu base de datos existente.

---

## 🔐 Variables de Entorno y Parámetros CI/CD (GitHub Secrets)

Los pipelines han sido modificados para hacer push a ECR y luego registrar/desplegar la Task Definition hacia ECS.
Debes configurar en **Settings** -> **Secrets and variables** -> **Actions**:

### Credenciales de AWS (Requeridas)
> [!CAUTION]
> **NUNCA pegues estas credenciales en texto plano (ni en README, ni en código, ni en chats de AI).** Configúralas exclusivamente como secretos en GitHub.

* **`AWS_ACCESS_KEY_ID`**
* **`AWS_SECRET_ACCESS_KEY`**
* **`AWS_SESSION_TOKEN`**

### Registros de Imágenes (Amazon ECR)
* `ECR_REGISTRY`
* `ECR_REPO_URL_BACKEND` (Ej: `123456789.dkr.ecr.us-east-1.amazonaws.com/tienda-backend`)
* `ECR_REPO_URL_FRONTEND`

---

## 🚀 Flujo del Pipeline CI/CD (GitHub Actions)

Los archivos `cicd-tienda-backend.yml` y `cicd-tienda-frontend.yml` automatizan el despliegue a ECS:

1. **Trigger**: Se dispara al realizar `push` a la rama `main` (o `deploy`) con cambios en las carpetas respectivas.
2. **Build & Push**: Construye las imágenes Docker y hace push a Amazon ECR etiquetadas con el SHA del commit.
3. **Descarga de Task Definition**: Recupera la Task Definition activa en el clúster ECS utilizando AWS CLI.
4. **Renderización (aws-actions/amazon-ecs-render-task-definition)**: Actualiza la imagen en la Task Definition con el nuevo tag de ECR.
5. **Despliegue a ECS (aws-actions/amazon-ecs-deploy-task-definition)**: Registra la nueva Task Definition y actualiza el Servicio en ECS. Espera hasta que el servicio sea estable.

---

## 📊 Autoscaling y Métricas (CloudWatch)

- **Target Tracking**: ECS está configurado para autoescalar basado en la métrica `ECSServiceAverageCPUUtilization` (objetivo del 50%).
- **Logs**: Todos los logs de los contenedores (`/ecs/tienda-frontend`, `/ecs/tienda-ventas`, `/ecs/tienda-despachos`) se envían automáticamente a **Amazon CloudWatch**.
