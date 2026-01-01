@echo off
echo ====================================
echo FMAT Archive - Setup Script
echo ====================================
echo.

REM Verificar que estamos en la raiz del proyecto
if not exist "docker-compose.yml" (
    echo Error: Este script debe ejecutarse desde la raiz del proyecto Fmat_Archive
    pause
    exit /b 1
)

echo [1/6] Verificando prerequisitos...
echo.

REM Verificar Node.js
node -v >nul 2>&1
if errorlevel 1 (
    echo [X] Node.js no encontrado. Instala Node.js v20+ desde https://nodejs.org/
    pause
    exit /b 1
) else (
    echo [OK] Node.js instalado
)

REM Verificar Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [X] Docker no encontrado. Instala Docker Desktop desde https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
) else (
    echo [OK] Docker instalado
)

echo.
echo [2/6] Creando archivos de configuracion...

REM Crear archivo .env en raiz
if not exist ".env" (
    (
        echo DB_USER=admin
        echo DB_PASSWORD=root
        echo DB_NAME=fmat_archive
        echo DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"
    ) > .env
    echo [OK] Archivo .env creado en raiz
) else (
    echo [OK] Archivo .env ya existe en raiz
)

REM Copiar .env a backend
if not exist "backend\.env" (
    copy .env backend\.env >nul
    echo [OK] Archivo .env copiado a backend
) else (
    echo [OK] Archivo .env ya existe en backend
)

echo.
echo [3/6] Instalando dependencias del backend...
cd backend
call npm install
if errorlevel 1 (
    echo [X] Error instalando dependencias del backend
    cd ..
    pause
    exit /b 1
)
cd ..
echo [OK] Dependencias del backend instaladas

echo.
echo [4/6] Instalando dependencias del frontend...
cd frontend
call npm install
if errorlevel 1 (
    echo [X] Error instalando dependencias del frontend
    cd ..
    pause
    exit /b 1
)
cd ..
echo [OK] Dependencias del frontend instaladas

echo.
echo [5/6] Levantando contenedores Docker...
docker-compose up -d
if errorlevel 1 (
    echo [X] Error levantando contenedores Docker
    echo Asegurate de que Docker Desktop este ejecutandose
    pause
    exit /b 1
)
echo [OK] Contenedores Docker iniciados

echo.
echo Esperando a que la base de datos este lista...
timeout /t 5 /nobreak >nul

echo.
echo [6/6] Sincronizando esquema de base de datos...
cd backend
call npx prisma db push
if errorlevel 1 (
    echo [X] Error sincronizando base de datos
    cd ..
    pause
    exit /b 1
)
cd ..
echo [OK] Base de datos sincronizada

echo.
echo ====================================
echo Setup completado exitosamente!
echo ====================================
echo.
echo Proximos pasos:
echo.
echo 1. Abre 3 terminales en VS Code
echo.
echo    Terminal 1 - Base de datos:
echo    docker-compose up -d
echo.
echo    Terminal 2 - Backend:
echo    cd backend
echo    npm run dev
echo.
echo    Terminal 3 - Frontend:
echo    cd frontend
echo    npm start
echo.
echo 2. Abre tu navegador en http://localhost:4200
echo.
echo Para mas informacion, consulta ONBOARDING.md
echo.
pause
