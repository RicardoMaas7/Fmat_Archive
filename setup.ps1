# Fmat_Archive - Setup Script para Windows
# Ejecutar en PowerShell

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "FMAT Archive - Setup Script" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en la raiz del proyecto
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "[X] Error: Este script debe ejecutarse desde la raiz del proyecto Fmat_Archive" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "[1/6] Verificando prerequisitos..." -ForegroundColor Yellow
Write-Host ""

# Verificar Node.js
try {
    $nodeVersion = node -v
    Write-Host "[OK] Node.js instalado: $nodeVersion" -ForegroundColor Green
    
    # Verificar version minima (v20+)
    $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    if ($versionNumber -lt 20) {
        Write-Host "[!] Advertencia: Se requiere Node.js v20+. Tu version es $nodeVersion" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[X] Node.js no encontrado. Instala Node.js v20+ desde https://nodejs.org/" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar npm
try {
    $npmVersion = npm -v
    Write-Host "[OK] npm instalado: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] npm no encontrado" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar Git
try {
    $gitVersion = git --version
    Write-Host "[OK] $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Git no encontrado. Instala Git desde https://git-scm.com/" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar Docker
try {
    $dockerVersion = docker --version
    Write-Host "[OK] $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no encontrado. Instala Docker Desktop desde https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "[OK] $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker Compose no encontrado" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar que Docker este corriendo
try {
    docker ps | Out-Null
    Write-Host "[OK] Docker esta corriendo" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no esta corriendo. Abre Docker Desktop e intenta nuevamente" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "[2/6] Creando archivos de configuracion..." -ForegroundColor Yellow

# Crear archivo .env en raiz
if (-not (Test-Path ".env")) {
    @"
DB_USER=admin
DB_PASSWORD=root
DB_NAME=fmat_archive
DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "[OK] Archivo .env creado en raiz" -ForegroundColor Green
} else {
    Write-Host "[OK] Archivo .env ya existe en raiz" -ForegroundColor Green
}

# Copiar .env a backend
if (-not (Test-Path "backend\.env")) {
    Copy-Item ".env" "backend\.env"
    Write-Host "[OK] Archivo .env copiado a backend" -ForegroundColor Green
} else {
    Write-Host "[OK] Archivo .env ya existe en backend" -ForegroundColor Green
}

Write-Host ""
Write-Host "[3/6] Instalando dependencias del backend..." -ForegroundColor Yellow
Set-Location backend
$npmInstall = npm install 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Error instalando dependencias del backend" -ForegroundColor Red
    Write-Host $npmInstall -ForegroundColor Red
    Set-Location ..
    Read-Host "Presiona Enter para salir"
    exit 1
}
Set-Location ..
Write-Host "[OK] Dependencias del backend instaladas" -ForegroundColor Green

Write-Host ""
Write-Host "[4/6] Instalando dependencias del frontend..." -ForegroundColor Yellow
Set-Location frontend
$npmInstall = npm install 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Error instalando dependencias del frontend" -ForegroundColor Red
    Write-Host $npmInstall -ForegroundColor Red
    Set-Location ..
    Read-Host "Presiona Enter para salir"
    exit 1
}
Set-Location ..
Write-Host "[OK] Dependencias del frontend instaladas" -ForegroundColor Green

Write-Host ""
Write-Host "[5/6] Levantando contenedores Docker..." -ForegroundColor Yellow
$dockerCompose = docker-compose up -d 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Error levantando contenedores Docker" -ForegroundColor Red
    Write-Host $dockerCompose -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}
Write-Host "[OK] Contenedores Docker iniciados" -ForegroundColor Green

Write-Host ""
Write-Host "Esperando a que la base de datos este lista..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "[6/6] Sincronizando esquema de base de datos..." -ForegroundColor Yellow
Set-Location backend
$prismaPush = npx prisma db push 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Error sincronizando base de datos" -ForegroundColor Red
    Write-Host $prismaPush -ForegroundColor Red
    Set-Location ..
    Read-Host "Presiona Enter para salir"
    exit 1
}
Set-Location ..
Write-Host "[OK] Base de datos sincronizada" -ForegroundColor Green

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Setup completado exitosamente!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abre 3 terminales en VS Code" -ForegroundColor White
Write-Host ""
Write-Host "   Terminal 1 - Base de datos:" -ForegroundColor Cyan
Write-Host "   docker-compose up -d" -ForegroundColor White
Write-Host ""
Write-Host "   Terminal 2 - Backend:" -ForegroundColor Cyan
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "   Terminal 3 - Frontend:" -ForegroundColor Cyan
Write-Host "   cd frontend" -ForegroundColor White
Write-Host "   npm start" -ForegroundColor White
Write-Host ""
Write-Host "2. Abre tu navegador en http://localhost:4200" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para mas informacion, consulta ONBOARDING.md" -ForegroundColor Cyan
Write-Host ""
Read-Host "Presiona Enter para salir"
