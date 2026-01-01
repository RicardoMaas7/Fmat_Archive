# Checklist de Verificación

Lista de verificación rápida para validar el entorno de desarrollo.

## Prerequisitos

- [ ] Node.js v20+ instalado (
ode -v)
- [ ] Docker Desktop ejecutándose
- [ ] Git instalado

## Configuración

- [ ] Repositorio clonado
- [ ] Archivo .env en raíz y ackend/.env creados
- [ ] Dependencias instaladas: ackend/node_modules/ y rontend/node_modules/

## Infraestructura

- [ ] Contenedores activos (docker ps muestra mat_archive_db y mat_archive_adminer)
- [ ] Adminer accesible en http://localhost:8080
- [ ] Schema sincronizado (
px prisma db push sin errores)

## Servicios

- [ ] Backend corriendo (
pm run dev sin errores)
- [ ] Frontend compilando (
pm start sin errores)
- [ ] Aplicación accesible en http://localhost:4200

## Validación Automatizada

Ejecutar script de validación:
`ash
node check-env.js
`

Para verificación detallada, consultar [ONBOARDING.md](onboarding.md).
