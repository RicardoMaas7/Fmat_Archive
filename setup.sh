#!/bin/bash

echo "===================================="
echo "FMAT Archive - Setup Script"
echo "===================================="
echo ""

# Verificar que estamos en la raiz del proyecto
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: Este script debe ejecutarse desde la raiz del proyecto Fmat_Archive"
    exit 1
fi

echo "[1/6] Verificando prerequisitos..."
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "[X] Node.js no encontrado. Instala Node.js v20+ desde https://nodejs.org/"
    exit 1
else
    echo "[OK] Node.js instalado: $(node -v)"
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "[X] npm no encontrado"
    exit 1
else
    echo "[OK] npm instalado: $(npm -v)"
fi

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "[X] Docker no encontrado. Instala Docker Desktop desde https://www.docker.com/products/docker-desktop/"
    exit 1
else
    echo "[OK] Docker instalado: $(docker --version)"
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "[X] Docker Compose no encontrado"
    exit 1
else
    echo "[OK] Docker Compose instalado: $(docker-compose --version)"
fi

echo ""
echo "[2/6] Creando archivos de configuracion..."

# Crear archivo .env en raiz
if [ ! -f ".env" ]; then
    cat > .env << EOF
DB_USER=admin
DB_PASSWORD=root
DB_NAME=fmat_archive
DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"
EOF
    echo "[OK] Archivo .env creado en raiz"
else
    echo "[OK] Archivo .env ya existe en raiz"
fi

# Copiar .env a backend
if [ ! -f "backend/.env" ]; then
    cp .env backend/.env
    echo "[OK] Archivo .env copiado a backend"
else
    echo "[OK] Archivo .env ya existe en backend"
fi

echo ""
echo "[3/6] Instalando dependencias del backend..."
cd backend
npm install
if [ $? -ne 0 ]; then
    echo "[X] Error instalando dependencias del backend"
    exit 1
fi
cd ..
echo "[OK] Dependencias del backend instaladas"

echo ""
echo "[4/6] Instalando dependencias del frontend..."
cd frontend
npm install
if [ $? -ne 0 ]; then
    echo "[X] Error instalando dependencias del frontend"
    exit 1
fi
cd ..
echo "[OK] Dependencias del frontend instaladas"

echo ""
echo "[5/6] Levantando contenedores Docker..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "[X] Error levantando contenedores Docker"
    echo "Asegurate de que Docker Desktop este ejecutandose"
    exit 1
fi
echo "[OK] Contenedores Docker iniciados"

echo ""
echo "Esperando a que la base de datos este lista..."
sleep 5

echo ""
echo "[6/6] Sincronizando esquema de base de datos..."
cd backend
npx prisma db push
if [ $? -ne 0 ]; then
    echo "[X] Error sincronizando base de datos"
    exit 1
fi
cd ..
echo "[OK] Base de datos sincronizada"

echo ""
echo "===================================="
echo "Setup completado exitosamente!"
echo "===================================="
echo ""
echo "Proximos pasos:"
echo ""
echo "1. Abre 3 terminales en VS Code"
echo ""
echo "   Terminal 1 - Base de datos:"
echo "   docker-compose up -d"
echo ""
echo "   Terminal 2 - Backend:"
echo "   cd backend && npm run dev"
echo ""
echo "   Terminal 3 - Frontend:"
echo "   cd frontend && npm start"
echo ""
echo "2. Abre tu navegador en http://localhost:4200"
echo ""
echo "Para mas informacion, consulta ONBOARDING.md"
echo ""
