# Fmat_Archive

Repositorio centralizado de recursos académicos de FMAT: exámenes, guías y material de estudio organizados en una interfaz tipo Retro OS. Desarrollado por estudiantes para estudiantes.

## Inicio Rápido

### Prerrequisitos

- **Node.js v20+**: https://nodejs.org/
- **Docker Desktop**: https://www.docker.com/products/docker-desktop/
  - Windows: Requiere WSL 2 habilitado
  - Mac/Linux: Sin configuración adicional

### Configuración Inicial

#### Opción A: Setup Automatizado (Recomendado)

**Windows PowerShell:**
```powershell
.\setup.ps1
```

**Windows CMD:**
```cmd
setup.bat
```

**Linux/Mac:**
```bash
chmod +x setup.sh
./setup.sh
```

El script automatiza:
- Verificación de prerequisitos
- Creación de archivos de configuración
- Instalación de dependencias
- Inicialización de base de datos

#### Opción B: Setup Manual

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/RicardoMaas7/Fmat_Archive.git
   cd Fmat_Archive
   ```

2. **Configurar variables de entorno**
   
   Crear `.env` en la raíz del proyecto:
   ```ini
   DB_USER=admin
   DB_PASSWORD=root
   DB_NAME=fmat_archive
   DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"
   ```
   
   Copiar a carpeta backend:
   ```bash
   cp .env backend/.env
   ```

3. **Instalar dependencias**
   ```bash
   # Backend
   cd backend
   npm install
   
   # Frontend
   cd ../frontend
   npm install
   cd ..
   ```

4. **Levantar base de datos**
   ```bash
   docker-compose up -d
   ```

5. **Sincronizar esquema de base de datos**
   ```bash
   cd backend
   npx prisma db push
   ```

### Validación del Entorno

Verificar configuración completa:
```bash
node check-env.js
```

### Ejecutar el Proyecto

Requiere tres terminales:

**Terminal 1 - Base de datos:**
```bash
docker-compose up -d
```

**Terminal 2 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 3 - Frontend:**
```bash
cd frontend
npm start
```

Aplicación disponible en: http://localhost:4200

## Documentación

- **[ONBOARDING.md](onboarding.md)** - Guía completa de configuración, troubleshooting y flujo de trabajo
- **[REFERENCE.md](REFERENCE.md)** - Referencia rápida de comandos, URLs y credenciales
- **[CHECKLIST.md](CHECKLIST.md)** - Lista de verificación para validación de entorno

## Stack Tecnológico

- **Frontend**: Angular 21
- **Backend**: Node.js + Express
- **ORM**: Prisma
- **Base de Datos**: PostgreSQL 16
- **Infraestructura**: Docker + Docker Compose
