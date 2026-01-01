# Guía de Configuración para Desarrolladores

Esta guía detalla el proceso completo de configuración del entorno de desarrollo. El proyecto utiliza una arquitectura híbrida: base de datos en Docker, frontend y backend ejecutándose nativamente para desarrollo ágil.

## 1. Prerrequisitos

### 1.1 Herramientas Requeridas

**Node.js v20+**: https://nodejs.org/
- Verificar: `node -v` (debe mostrar v20.x.x o superior)
- npm: `npm -v`

**Git**: https://git-scm.com/
- Verificar: `git --version`

**Docker Desktop**: https://www.docker.com/products/docker-desktop/
- Verificar: `docker --version` y `docker-compose --version`
- Debe estar ejecutándose antes de iniciar el proyecto

### 1.2 Configuración WSL 2 (Windows Únicamente)

Docker Desktop requiere WSL 2 en Windows.

**Instalación:**
```powershell
# PowerShell como Administrador
wsl --install
```

**Verificación:**
```powershell
wsl --list --verbose
```

Debe mostrar una distribución con VERSION 2.

**Actualización desde WSL 1:**
```powershell
wsl --set-default-version 2
wsl --set-version Ubuntu 2
```

Documentación: https://learn.microsoft.com/es-es/windows/wsl/install

### 1.3 Extensiones VS Code Recomendadas

- Prisma
- Docker
- ESLint
- Angular Language Service

## 2. Configuración Inicial

**Nota**: Los scripts de setup automatizado (`setup.ps1`, `setup.bat`, `setup.sh`) ejecutan automáticamente los pasos 2.1 a 3.3. Se recomienda el setup manual la primera vez para comprender el proceso.

### 2.1 Clonar Repositorio

```bash
git clone https://github.com/RicardoMaas7/Fmat_Archive.git
cd Fmat_Archive
```

### 2.2 Variables de Entorno

Se requieren archivos `.env` en dos ubicaciones:
1. Raíz del proyecto (para Docker Compose)
2. `backend/` (para Prisma Client)

**Creación automatizada:**

```bash
# Crear en raíz
echo DB_USER=admin > .env
echo DB_PASSWORD=root >> .env
echo DB_NAME=fmat_archive >> .env
echo DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public" >> .env

# Copiar a backend
cp .env backend/.env
```

**Creación manual:**

Contenido para `.env` y `backend/.env`:

```ini
DB_USER=admin
DB_PASSWORD=root
DB_NAME=fmat_archive
DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"
```

**Importante**: Archivos `.env` están en `.gitignore` y no deben ser versionados.

### 2.3 Instalación de Dependencias

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install

# Retornar a raíz
cd ..
```

## 3. Base de Datos

### 3.1 Iniciar Contenedores Docker

Verificar que Docker Desktop esté ejecutándose, luego:

```bash
docker-compose up -d
```

Verificar estado:
```bash
docker ps
```

Debe mostrar `fmat_archive_db` y `fmat_archive_adminer` en estado "Up".

### 3.2 Verificar Conexión

Acceder a Adminer: http://localhost:8080

Credenciales:

| Campo | Valor |
|-------|-------|
| Sistema | PostgreSQL |
| Servidor | db |
| Usuario | admin |
| Contraseña | root |
| Base de datos | fmat_archive |

### 3.3 Sincronizar Schema con Prisma

```bash
cd backend
npx prisma db push
```

Salida esperada: "Your database is now in sync with your Prisma schema"

Verificar en Adminer: deben aparecer tablas `User`, `Subject`, `Resource`, etc.

### 3.4 Validación (Opcional)

```bash
node check-env.js
```

Verifica prerequisitos, archivos de configuración, dependencias y estado de contenedores.

## 4. Flujo de Trabajo Diario

Requiere tres terminales en VS Code:

### Terminal 1: Base de Datos

```bash
docker-compose up -d
```

Verificar: `docker ps` debe mostrar contenedores activos.

### Terminal 2: Backend

```bash
cd backend
npm run dev
```

Salida esperada: "Server running on port 3000"
Database connected
```

**Verificar:** No debe mostrar errores de conexión a la base de datos.

### Terminal 3: Frontend

Ejecuta la aplicación Angular en modo desarrollo.

```bash
cd frontend
npm start
```

**Salida esperada:**
```
Application bundle generation complete. [x.xxx seconds]
Local: http://localhost:4200/
```

### Terminal 3: Frontend

```bash
cd frontend
npm start
```

Aplicación disponible en: http://localhost:4200

### Detener Servicios

```bash
# Docker
docker-compose down

# Backend y Frontend: Ctrl+C en terminales respectivas
```

## 5. Troubleshooting

### Port 5432 already allocated

**Causa**: PostgreSQL local ejecutándose fuera de Docker

**Solución**:
- Windows: Detener servicio PostgreSQL en services.msc
- Alternativa: Cambiar puerto en docker-compose.yml y actualizar DATABASE_URL

### Cannot connect to Docker daemon

**Causa**: Docker Desktop no está ejecutándose

**Solución**:
1. Iniciar Docker Desktop
2. Verificar con `docker ps`
3. Ejecutar `docker-compose up -d`

### Prisma connection failed

**Causa**: Archivo `.env` faltante o contenedores inactivos

**Solución**:
1. Verificar Docker: `docker ps`
2. Confirmar existencia de `backend/.env`
3. Reiniciar contenedores: `docker-compose restart`
4. Verificar credenciales en Adminer (http://localhost:8080)

### Error: `npm install` falla con errores de permisos

**Causa:** Problemas de permisos en la carpeta de instalación.

### npm install fails

**Causa**: Problemas de permisos

**Solución**:
- Windows: Ejecutar terminal como Administrador
- Mac/Linux: Evitar sudo, verificar permisos del proyecto

### Database schema desincronizado

**Causa**: Cambios en schema.prisma sin aplicar

**Solución**:
```bash
cd backend
npx prisma db push
```

### Frontend no compila

**Causa**: Dependencias corruptas o desactualizadas

**Solución**:
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm start
```

## 6. Comandos de Referencia

### Docker
```bash
docker-compose up -d              # Iniciar servicios
docker ps                         # Ver estado
docker-compose logs -f            # Ver logs en tiempo real
docker-compose restart db         # Reiniciar servicio específico
docker-compose down               # Detener servicios
docker-compose down -v            # Detener y eliminar volúmenes
```

### Prisma
```bash
npx prisma db push                # Sincronizar schema
npx prisma studio                 # Abrir editor visual
npx prisma generate               # Regenerar cliente
npx prisma migrate status         # Estado de migraciones
```

### Backend
```bash
npm run dev                       # Desarrollo (hot-reload)
npm start                         # Producción
```

### Frontend
```bash
npm start                         # Desarrollo
npm run build                     # Build de producción
npm test                          # Tests
```

## 7. Recursos

- Prisma: https://www.prisma.io/docs
- Angular: https://angular.dev
- Docker Compose: https://docs.docker.com/compose/
- PostgreSQL: https://www.postgresql.org/docs/

## 8. Verificación de Entorno

Consulta [CHECKLIST.md](CHECKLIST.md) para verificación completa.

Verificación rápida:
- [ ] Node.js v20+ instalado
- [ ] Docker Desktop ejecutándose
- [ ] Archivos `.env` en raíz y backend/
- [ ] Dependencias instaladas
- [ ] Contenedores activos
- [ ] Prisma sincronizado
- [ ] Backend sin errores de conexión
- [ ] Frontend compilando correctamente
- [ ] Aplicación accesible en http://localhost:4200