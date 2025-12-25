# Developer Setup Guide - FMAT Archive

Sigue esta guía paso a paso para configurar el entorno de desarrollo local. El proyecto utiliza una arquitectura híbrida: Base de datos en Docker, pero Frontend y Backend se ejecutan nativamente en el host para mayor velocidad de desarrollo.

## 1. Prerrequisitos de Software

Antes de clonar el repositorio, instala las siguientes herramientas en tu sistema operativo:

* **Node.js (LTS Version):** [https://nodejs.org/](https://nodejs.org/)
    * Verificar instalación: `node -v` (Debe ser v18 o superior)
    * Verificar npm: `npm -v`
* **Git:** [https://git-scm.com/](https://git-scm.com/)
    * Verificar instalación: `git --version`

### 1.1 Configuración de WSL 2 (Solo Windows)

**Docker Desktop en Windows requiere WSL 2.** Si no lo tienes instalado, sigue estos pasos:

1. **Abrir PowerShell como Administrador** y ejecutar:
   ```powershell
   wsl --install
   ```
   
2. **Reiniciar tu computadora** cuando se solicite.

3. **Después del reinicio**, se abrirá automáticamente una terminal de Ubuntu. Crea tu usuario y contraseña de Linux.

4. **Verificar la instalación:**
   ```powershell
   wsl --list --verbose
   ```
   Debe mostrar una distribución (ej: Ubuntu) con VERSION 2.

5. **Si ya tenías WSL 1 instalado**, actualiza a WSL 2:
   ```powershell
   wsl --set-default-version 2
   wsl --set-version Ubuntu 2
   ```

**Recursos adicionales:** [Documentación oficial de Microsoft WSL](https://learn.microsoft.com/es-es/windows/wsl/install)

---

* **Docker Desktop:** [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
    * Verificar instalación: `docker --version` y `docker-compose --version`
    * *Importante:* Asegúrate de que Docker Desktop esté usando WSL 2 como backend (Settings → General → "Use the WSL 2 based engine"). Docker debe estar ejecutándose antes de iniciar el proyecto.
* **Angular CLI:**
    * Ejecutar en terminal: `npm install -g @angular/cli`
    * Verificar instalación: `ng version`

**Extensiones recomendadas para VS Code:**
* **Prisma** (Sintaxis y formateo para esquemas de BD).
* **Docker** (Gestión de contenedores).
* **ESLint** (Linter para TypeScript/Javascript).

---

## 2. Configuración Inicial

### 2.1 Clonar Repositorio
```bash
git clone https://github.com/RicardoMaas7/Fmat_Archive.git
cd Fmat_Archive
```



### 2.2 Configuración de Variables de Entorno

El sistema requiere la configuración de variables de entorno en **dos ubicaciones** distintas para garantizar la conexión entre los contenedores y el servicio de backend local.

**Archivos requeridos:**
1.  `./.env` (Raíz del proyecto - Consumido por Docker Compose).
2.  `./backend/.env` (Directorio del Backend - Consumido por Prisma Client).

**Instrucciones:**
Crea **AMBOS** archivos con el **MISMO** contenido. Puedes copiar el primer archivo al segundo:

```bash
# Crear archivo en la raíz
echo 'DB_USER=admin' > .env
echo 'DB_PASSWORD=root' >> .env
echo 'DB_NAME=fmat_archive' >> .env
echo 'DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"' >> .env

# Copiar a la carpeta backend
cp .env backend/.env
```

**O crea manualmente ambos archivos con el siguiente contenido:**

```ini
# --- Infraestructura (Docker) ---
DB_USER=admin
DB_PASSWORD=root
DB_NAME=fmat_archive

# --- Backend (Prisma ORM) ---
# Connection String: postgresql://USER:PASSWORD@HOST:PORT/DB?schema=public
DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public" 
```

Nota: Estos archivos están excluidos del control de versiones (.gitignore) por seguridad. No los subas al repositorio.

### 2.3 Instalación de Dependencias

Instala las librerías necesarias tanto para el frontend como para el backend.

**Desde la raíz del proyecto (`Fmat_Archive/`), ejecuta:**

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install

# Regresar a raíz
cd ..
```
## 3. Infraestructura y Base de Datos
Utilizamos Docker Compose para levantar PostgreSQL y Adminer (interfaz visual).

### 3.1 Levantar Servicios
En la raíz del proyecto, ejecuta:
```bash 
docker-compose up -d
```
### 3.2 Verificar Estado

Accede a http://localhost:8080 (Adminer).

Sistema: PostgreSQL 

Servidor: db

Usuario: admin

Contraseña: root

Base de datos: fmat_archive

Si puedes iniciar sesión, el contenedor de base de datos está operativo.

### 3.3 Sincronizar Schema (Prisma)
Para crear las tablas definidas en el esquema, ejecuta el push de Prisma:
```bash 
cd backend
npx prisma db push
```
Salida esperada: ```Your database is now in sync with your Prisma schema.```

## 4. Flujo de Trabajo Diario
Para desarrollar, necesitarás tres terminales abiertas en VS Code. **Ejecuta en este orden:**

### Terminal 1: Infraestructura (Primero)
Mantener el contenedor de base de datos activo.
```bash
docker-compose up -d
```
**Verificar:** `docker ps` debe mostrar contenedores `db` y `adminer` corriendo.

### Terminal 2: Backend (Segundo)
Ejecuta el servidor Node.js en modo watch.

```bash
cd backend
npm run dev
```
**Verificar:** Debe mostrar "Server running on port..." sin errores de conexión.

### Terminal 3: Frontend (Tercero)
Ejecuta la aplicación cliente.

```bash
cd frontend
ng serve
```
**Verificar:** Compila sin errores y muestra "Compiled successfully".

La aplicación estará disponible en: http://localhost:4200

### Detener servicios al finalizar:
```bash
# Detener Docker (desde la raíz)
docker-compose down

# Frontend y Backend: Ctrl+C en sus respectivas terminales
```
## 5. Troubleshooting

### Error: `"Port 5432 is already allocated"`
**Causa:** Tienes una instancia local de PostgreSQL corriendo en tu máquina fuera de Docker.

**Solución:** Detén el servicio de PostgreSQL de Windows/Mac o cambia el puerto en `docker-compose.yml`.

### Error: Connection failed en Prisma
**Causa:** No copiaste el archivo `.env` a la carpeta `backend/` o el contenedor de Docker no está corriendo.

**Solución:** 
1. Verifica que Docker esté corriendo: `docker ps`
2. Verifica que existe `backend/.env` con la variable `DATABASE_URL`
3. Reinicia el contenedor: `docker-compose restart`

### Error: `"ng is not recognized"`
**Causa:** No se instaló Angular CLI globalmente.

**Solución:** Ejecuta `npm install -g @angular/cli`

### Error: Docker Desktop no está corriendo
**Causa:** Docker Desktop no se inició o se cerró.

**Solución:** Abre Docker Desktop y espera a que aparezca el ícono verde de "running" antes de ejecutar `docker-compose up`.

### Error: `npm install` falla con errores de permisos
**Causa:** Problemas de permisos en la carpeta de instalación.

**Solución:** 
- Windows: Ejecuta la terminal como Administrador
- Mac/Linux: Evita usar `sudo`, verifica permisos de la carpeta del proyecto