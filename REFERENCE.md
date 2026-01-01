# Referencia Rápida - Fmat_Archive

## URLs de Desarrollo

| Servicio | URL | Descripción |
|----------|-----|-------------|
| Frontend | http://localhost:4200 | Aplicación Angular |
| Backend API | http://localhost:3000 | API REST de Node.js |
| Adminer | http://localhost:8080 | Interfaz visual de PostgreSQL |
| Prisma Studio | http://localhost:5555 | Editor visual de datos (`npx prisma studio`) |

## Credenciales de Base de Datos

### PostgreSQL (Docker)

| Campo | Valor |
|-------|-------|
| Host | localhost |
| Puerto | 5432 |
| Usuario | admin |
| Contraseña | root |
| Base de datos | fmat_archive |

### Adminer

| Campo | Valor |
|-------|-------|
| Sistema | PostgreSQL |
| Servidor | db (Docker interno) / localhost (host) |
| Usuario | admin |
| Contraseña | root |
| Base de datos | fmat_archive |

### Connection String (Prisma)

```
postgresql://admin:root@localhost:5432/fmat_archive?schema=public
```

## Comandos Esenciales

### Setup Automatizado (Primera vez)

```powershell
# Windows PowerShell (Recomendado)
.\setup.ps1

# Windows CMD
setup.bat

# Linux/Mac
chmod +x setup.sh
./setup.sh
```

### Validar Entorno

```bash
# Verificar que todo está configurado correctamente
node check-env.js
```

### Inicio Rápido (3 terminales)

```bash
# Terminal 1: Base de datos
docker-compose up -d

# Terminal 2: Backend
cd backend
npm run dev

# Terminal 3: Frontend
cd frontend
npm start
```

### Docker

```bash
# Levantar servicios
docker-compose up -d

# Ver estado
docker ps

# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar base de datos
docker-compose restart db

# Detener todo
docker-compose down

# Detener y eliminar volúmenes (BORRA DATOS)
docker-compose down -v
```

### Prisma

```bash
# Sincronizar schema con BD (desarrollo)
npx prisma db push

# Abrir editor visual de datos
npx prisma studio

# Regenerar cliente de Prisma (después de cambios al schema)
npx prisma generate

# Formatear archivo schema.prisma
npx prisma format
```

### Backend

```bash
# Desarrollo (hot-reload)
npm run dev

# Producción
npm start
```

### Frontend

```bash
# Desarrollo
npm start

# Build de producción
npm run build

# Tests
npm test

# Generar componente
ng generate component <nombre>
```

## Estructura de Archivos Clave

```
Fmat_Archive/
├── .env                          # Variables de entorno (Docker)
├── docker-compose.yml            # Configuración de contenedores
├── check-env.js                  # Script de validación
│
├── backend/
│   ├── .env                      # Variables de entorno (Backend)
│   ├── package.json              # Dependencias backend
│   ├── src/
│   │   └── index.js              # Punto de entrada del servidor
│   └── prisma/
│       └── schema.prisma         # Modelo de datos
│
├── frontend/
│   ├── package.json              # Dependencias frontend
│   ├── angular.json              # Configuración Angular
│   └── src/
│       ├── main.ts               # Punto de entrada
│       └── app/                  # Componentes de la app
│
└── database/
    └── pgdata/                   # Datos de PostgreSQL (volumen)
```

## Puertos

| Puerto | Servicio |
|--------|----------|
| 3000 | Backend API |
| 4200 | Frontend |
| 5432 | PostgreSQL |
| 5555 | Prisma Studio (cuando se ejecuta) |
| 8080 | Adminer |

## Variables de Entorno

Archivo `.env` (raíz y backend/):

```bash
DB_USER=admin
DB_PASSWORD=root
DB_NAME=fmat_archive
DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"
```

## Troubleshooting

| Problema | Solución |
|----------|----------|
| Puerto 5432 ocupado | Detener PostgreSQL local o modificar puerto en docker-compose.yml |
| Docker no conecta | Verificar que Docker Desktop esté ejecutándose |
| Prisma connection failed | Confirmar existencia de backend/.env y estado de contenedores |
| Frontend no compila | Eliminar node_modules y reinstalar dependencias |
| Database schema desincronizado | Ejecutar npx prisma db push desde backend/ |

## Recursos Externos

- Prisma Documentation: https://www.prisma.io/docs
- Angular Documentation: https://angular.dev
- Docker Documentation: https://docs.docker.com
