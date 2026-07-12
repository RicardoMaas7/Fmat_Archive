# Fmat_Archive — Resumen del proyecto (handoff para IA/desarrolladores)

> Documento de contexto pensado para que cualquier IA o desarrollador nuevo entienda el proyecto sin leer todo el código. Actualizado: julio 2026.

## 1. Qué es

Repositorio centralizado de recursos académicos de la FMAT (Facultad de Matemáticas): exámenes, tareas, libros, apuntes y material de estudio, subidos por estudiantes y moderados antes de publicarse. La interfaz planeada es tipo "Retro OS". Proyecto hecho por estudiantes para estudiantes.

**Estado actual: fase muy temprana (esqueleto/arquitectura).** La infraestructura, el esquema de datos y la documentación de onboarding están listos; la lógica de negocio y la UI todavía no están implementadas.

## 2. Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Angular 21 (standalone components, signals, Vitest) |
| Backend | Node.js + Express 4 (ES modules) |
| ORM | Prisma 5 |
| Base de datos | PostgreSQL 16 (Docker, `postgres:16-alpine`) |
| Admin BD | Adminer en `localhost:8080` |
| Infraestructura dev | Docker Compose (solo la BD corre en Docker; front y back corren nativos) |

## 3. Estructura del repositorio

```
Fmat_Archive/
├── backend/
│   ├── src/index.js          # Servidor Express — TODO el backend actual (38 líneas)
│   └── prisma/schema.prisma  # Esquema completo de la BD (la pieza más importante)
├── frontend/                 # Scaffold recién generado de Angular 21 (sin rutas ni componentes propios)
│   └── src/app/              # app.ts, app.routes.ts (vacío), app.config.ts
├── docker-compose.yml        # Servicios: db (Postgres 16) + adminer
├── setup.sh / setup.ps1 / setup.bat  # Scripts de setup automatizado
├── check-env.js              # Validador del entorno de desarrollo
├── README.md                 # Inicio rápido
├── onboarding.md             # Guía detallada de configuración y troubleshooting
├── REFERENCE.md              # Comandos, URLs y credenciales de dev
└── CHECKLIST.md              # Checklist de validación del entorno
```

Nota: `frontend/` incluye archivos de instrucciones para agentes IA (`.claude/CLAUDE.md`, `AGENTS.md`, `.cursor/`, `.gemini/`, etc.) con las convenciones de Angular moderno que se deben seguir: componentes standalone, signals, `input()`/`output()`, `ChangeDetectionStrategy.OnPush`, control flow nativo (`@if`, `@for`), sin `ngClass`/`ngStyle`.

## 4. Modelo de datos (Prisma — ya definido)

El esquema en `backend/prisma/schema.prisma` define el dominio completo:

- **User**: email único, rol (`ADMIN` | `STUDENT`), `credits` (default 5), `isPremium`. Relación con recursos subidos y descargas.
- **AuthCode**: códigos de verificación por email con expiración → implica **login sin contraseña** (passwordless por código enviado al correo).
- **Subject**: materia con `name`, `slug` y `semester`.
- **Resource**: recurso académico. `type`: `EXAM` | `HOMEWORK` | `BOOK` | `NOTES` | `OTHER`; `status`: `PENDING` | `APPROVED` | `REJECTED` (flujo de moderación); campos `fileUrl`, `year`, `professor`; pertenece a un `Subject` y a un `uploader` (User).
- **DownloadLog**: registro de cada descarga con `cost` → implica **economía de créditos**: descargar cuesta créditos, subir material presumiblemente los otorga; usuarios premium probablemente exentos.

## 5. Lo que existe vs. lo que falta

**Hecho:**
- Esquema Prisma completo (dominio modelado).
- Docker Compose con Postgres + Adminer.
- Backend Express mínimo con 2 endpoints: `GET /api/health` y `GET /api/users` (prueba de conexión a BD).
- Scaffold de Angular 21 sin modificar.
- Documentación de onboarding muy completa (README, onboarding.md, REFERENCE.md, CHECKLIST.md, scripts de setup multiplataforma).

**Pendiente (todo el producto):**
- Autenticación por código de email (modelo `AuthCode` sin lógica).
- CRUD de recursos, subida de archivos (no hay storage definido para `fileUrl`).
- Flujo de moderación (aprobar/rechazar) y panel de admin.
- Lógica de créditos/descargas/premium.
- Toda la UI Angular (rutas vacías) incluida la estética "Retro OS".
- Tests (backend no tiene ninguno).

## 6. Cómo correr en desarrollo

```bash
# 1. Variables de entorno (.env en raíz Y copiado a backend/)
DB_USER=admin
DB_PASSWORD=root
DB_NAME=fmat_archive
DATABASE_URL="postgresql://admin:root@localhost:5432/fmat_archive?schema=public"

# 2. Base de datos
docker-compose up -d

# 3. Backend (puerto 3000)
cd backend && npm install && npx prisma db push && npm run dev

# 4. Frontend (puerto 4200)
cd frontend && npm install && npm start
```

- App: http://localhost:4200 · API: http://localhost:3000/api/health · Adminer: http://localhost:8080
- Validar entorno: `node check-env.js`

## 7. Convenciones y notas para quien continúe

- El esquema de BD se sincroniza con `npx prisma db push` (no hay migraciones formales todavía).
- Mensajes de commit en español, estilo convencional (`feat:`, `docs:`, `chore:`).
- El backend usa ES modules (`"type": "module"`).
- Credenciales de dev (admin/root) son solo locales; no hay manejo de secretos de producción aún.
- Repositorio hermano del mismo autor: `meridian-atlas` (herramienta de visualización de código, proyecto independiente).
