# DevOps-TendaLuktek

Proyecto Semestral de DevOps 2026. Guía completa de arquitectura, secretos de CI/CD, flujo de despliegue y comandos útiles para depuración.

---

## 🏗️ Arquitectura del Proyecto y Configuración de Puertos

El proyecto está dividido en tres componentes principales, cada uno con su propio `Dockerfile` y pipeline de GitHub Actions independiente:

| Capa / Componente | Puerto | Contenedor | Notas Técnicas |
| :--- | :--- | :--- | :--- |
| **Base de Datos (`db/`)** | `3306` | `tienda-db` | Motor MySQL. Se utiliza un volumen llamado `dbdata` para la persistencia de datos. |
| **Backend (`backend/`)** | `3001` | `tienda-backend` | Entorno Node.js. Depende de variables de entorno para conectarse a la base de datos (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, etc.). |
| **Frontend (`frontend/`)** | `80` | `tienda-frontend` | Servidor Nginx que sirve el build público del cliente para el navegador. |

> [!NOTE]
> **Estructura en el repositorio**: Cada capa tiene su directorio raíz (`frontend/`, `backend/`, `db/`) y los workflows residen en `.github/workflows/`.

---

## ⚙️ Variables de Entorno y Parámetros

Los secretos y credenciales requeridos en el repositorio deben configurarse en GitHub en **Settings** -> **Secrets and variables** -> **Actions**.

### Credenciales de AWS (Requeridas)
> [!WARNING]
> Las credenciales en **negrita** expiran y deben actualizarse **cada 4 horas**.

* **`AWS_ACCESS_KEY_ID`**
* **`AWS_SECRET_ACCESS_KEY`**
* **`AWS_SESSION_TOKEN`**
* `AWS_REGION`

### Registros de Imágenes (Amazon ECR)
* `ECR_REGISTRY`
* `ECR_REPO_URL_DB`
* `ECR_REPO_URL_BACKEND`
* `ECR_REPO_URL_FRONTEND`

### Destinos de Despliegue (Instancias EC2)
* `EC2_DB_INSTANCE_ID`
* `EC2_BACKEND_INSTANCE_ID`
* `EC2_FRONTEND_INSTANCE_ID`

---

## 🚀 Flujo y Lógica del Pipeline CI/CD

Cada uno de los tres archivos de workflow (`cicd-tienda-db.yml`, `cicd-tienda-backend.yml`, y `cicd-tienda-frontend.yml`) ejecuta de forma aislada las siguientes etapas:

1. **Trigger Condicional (`on: push`)**: El pipeline se dispara hacia la rama `main` solo si se detectan cambios específicos dentro de la carpeta de la capa correspondiente (`db/`, `backend/` o `frontend/`).
2. **Checkout & Auth**: Descarga el código en el runner temporal y configura las credenciales de AWS utilizando variables de entorno protegidas.
3. **Registry Login**: Autentica el runner contra Amazon ECR (Elastic Container Registry).
4. **Build & Push**: Construye la imagen Docker local mediante el `Dockerfile` de la capa, la etiqueta con la URL del registro y la sube a ECR.
5. **Deploy Remoto (SSM)**: Utiliza AWS Systems Manager (SSM) `send-command` para conectarse de forma segura a la instancia EC2 asignada sin exponer puertos SSH directos.
6. **Ejecución en EC2**: Remotamente, la instancia EC2 realiza login en ECR, ejecuta un `docker pull` de la nueva imagen, detiene/elimina el contenedor antiguo y levanta el nuevo contenedor.

> [!IMPORTANT]
> Antes de ejecutar los pipelines, recuerde agregar el rol IAM correspondiente a las instancias EC2, instalar Docker, y activar/arrancar el servicio de SSM Agent en cada una de las máquinas.

---

## 🛠️ Comandos Útiles para Verificación y Debugging

Si necesita interactuar con las instancias EC2 o verificar fallos, los comandos clave definidos en la guía son:

* **Estado de los contenedores**:
  ```bash
  docker ps
  ```

* **Inspección de fallos (logs)**:
  ```bash
  docker logs [nombre-contenedor]
  ```

* **Verificación de persistencia/datos (en la DB)**:
  ```bash
  sudo docker exec -it tienda-db mysql -u root -padmin123 -e "USE tienda_perritos; SELECT * FROM productos;"
  ```
