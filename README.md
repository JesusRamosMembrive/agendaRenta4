# Agenda Renta4 - Task Manager Manual

Sistema de gestión de tareas para control de calidad de sitios web.

## 🎯 Estado del Proyecto

**Fase**: 1 - Task Manager Manual
**Versión**: 0.1 (Día 1 completado)
**Fecha**: 2025-10-28

---

## 📊 Resumen Día 1 (COMPLETADO ✅)

### Backend Base Funcional

- ✅ Base de datos SQLite creada con 4 tablas
- ✅ 173 URLs reales importadas desde Excel
- ✅ 8 tipos de tareas configurados con periodicidades
- ✅ 1,038 tareas generadas para noviembre 2025
- ✅ 2 usuarios de prueba creados

### Estadísticas Actuales

```
📊 Base de Datos (agendaRenta4.db):
   - Secciones:    173 URLs activas
   - Tipos tareas:   8 tipos configurados
   - Tareas:      1038 pendientes (nov 2025)
   - Usuarios:       2 activos
```

---

## 🚀 Setup Rápido

### 1. Instalar Dependencias

```bash
pip install -r requirements.txt
```

### 2. Inicializar Base de Datos

```bash
python database.py
```

### 3. Cargar URLs desde Excel

```bash
python load_sections.py
```

### 4. Crear Tareas para un Periodo

```bash
# Mes específico
python create_tasks_for_period.py --period 2025-11

# Próximos 3 meses
python create_tasks_for_period.py --next-months 3
```

### 5. Poblar Usuarios de Prueba

```bash
python seed_users.py
```

### 6. Ejecutar Flask App

```bash
python app.py
```

Abrir: `http://localhost:5000`

---

## 📂 Estructura del Proyecto

```
agendaRenta4/
├── app.py                          # Flask app (en desarrollo)
├── database.py                     # Schema + inicialización ✅
├── load_sections.py                # Importar URLs desde Excel ✅
├── create_tasks_for_period.py     # Crear tareas manualmente ✅
├── seed_users.py                   # Poblar usuarios ✅
├── requirements.txt                # Dependencias ✅
├── .env.example                    # Configuración ejemplo
├── agendaRenta4.db                 # SQLite database ✅
├── templates/                      # Jinja2 templates (pendiente)
├── static/
│   ├── css/                        # CSS (pendiente)
│   └── js/                         # JavaScript (pendiente)
├── UI/
│   └── wireframes_html_...html     # Prototipo HTML original ✅
├── original-data/
│   └── 251028_Árbol web...xlsx     # Excel fuente ✅
└── docs/                           # Documentación
```

---

## 🛠️ Scripts Disponibles

### `database.py`

Inicializa la BD y pobla tipos de tareas.

```bash
# Crear BD + seed de tipos de tareas
python database.py

# Mostrar estadísticas
python database.py stats

# Recrear BD (⚠️ elimina datos)
python database.py drop
```

### `load_sections.py`

Importa URLs desde el Excel a la tabla `sections`.

```bash
python load_sections.py
# Output: 173 secciones cargadas
```

### `create_tasks_for_period.py`

Genera tareas manualmente para un periodo.

```bash
# Mes actual
python create_tasks_for_period.py

# Mes específico
python create_tasks_for_period.py --period 2025-12

# Próximos N meses
python create_tasks_for_period.py --next-months 6

# Mostrar estadísticas
python create_tasks_for_period.py --stats

# Modo silencioso
python create_tasks_for_period.py --period 2025-11 --quiet
```

### `seed_users.py`

Crea usuarios de prueba.

```bash
# Poblar usuarios
python seed_users.py

# Listar usuarios existentes
python seed_users.py --list
```

---

## 📋 Schema de Base de Datos

### Tabla `sections` (173 registros)

URLs/secciones a revisar.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER | PK |
| `name` | TEXT | Nombre descriptivo |
| `url` | TEXT | URL completa (unique) |
| `active` | BOOLEAN | Si está activa (default: 1) |
| `created_at` | TIMESTAMP | Fecha de creación |

### Tabla `task_types` (8 registros)

Tipos de tareas fijos con sus periodicidades.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER | PK |
| `name` | TEXT | Nombre interno (unique) |
| `display_name` | TEXT | Nombre visible |
| `periodicity` | TEXT | weekly/monthly/quarterly/biannual/yearly |
| `display_order` | INTEGER | Orden de visualización |

**Tipos configurados:**
1. Enlaces rotos (weekly)
2. Enlaces incorrectos (weekly)
3. Textos – erratas (monthly)
4. Información actualizada (monthly)
5. Preguntas frecuentes (quarterly)
6. CTAs (monthly)
7. Imágenes (monthly)
8. Diseño (quarterly)

### Tabla `tasks` (1038 registros)

Instancias de tareas (URL × tipo × periodo).

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER | PK |
| `section_id` | INTEGER | FK a sections |
| `task_type_id` | INTEGER | FK a task_types |
| `period` | TEXT | Formato "YYYY-MM" |
| `status` | TEXT | pending/ok/problem |
| `observations` | TEXT | Observaciones del usuario |
| `completed_date` | DATE | Fecha de completado |
| `completed_by` | TEXT | Quién completó |
| `created_at` | TIMESTAMP | Fecha de creación |

**Constraint**: UNIQUE(section_id, task_type_id, period)

### Tabla `users` (2 registros)

Usuarios para notificaciones.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER | PK |
| `name` | TEXT | Nombre completo |
| `email` | TEXT | Email (unique) |
| `notify_email` | BOOLEAN | Recibir notificaciones por email |
| `notify_browser` | BOOLEAN | Recibir notificaciones browser |
| `active` | BOOLEAN | Si está activo |
| `created_at` | TIMESTAMP | Fecha de creación |

---

## 🎯 Modelo de Periodicidad

**Periodicidad por TIPO de tarea** (no por URL):

- **Weekly**: Todas las URLs, todas las semanas (ej: Enlaces rotos)
- **Monthly**: Todas las URLs, cada mes (ej: Información actualizada)
- **Quarterly**: Todas las URLs, cada trimestre (ene/abr/jul/oct)
- **Biannual**: Todas las URLs, cada semestre (ene/jul)
- **Yearly**: Todas las URLs, una vez al año (enero)

**Ejemplo noviembre 2025**:
- ✅ Weekly: 173 tareas creadas
- ✅ Monthly: 173 tareas creadas
- ❌ Quarterly: No aplica (no es mes de trimestre)
- ❌ Biannual: No aplica
- ❌ Yearly: No aplica

**Total para nov 2025**: 6 tipos × 173 URLs = **1,038 tareas**

---

## 🔮 Próximos Pasos (Día 2)

### Templates + Pantalla Principal

- [ ] Template base con CSS del wireframe
- [ ] Pantalla "Inicio" (tabla con URLs + 8 tipos)
- [ ] Endpoint Flask: `GET /inicio`
- [ ] Endpoint Flask: `POST /tasks/update`
- [ ] ComboBox de periodos funcional

**Estimado**: 6-8 horas

---

## ⚙️ Configuración

### Variables de Entorno (.env)

Copiar `.env.example` a `.env` y configurar:

```bash
# Flask
SECRET_KEY=tu-clave-secreta-aqui

# Database
DATABASE_PATH=agendaRenta4.db

# SMTP (para notificaciones email)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USE_TLS=True
EMAIL_USER=tu-email@gmail.com
EMAIL_PASS=tu-password-de-aplicacion
EMAIL_FROM=Agenda Renta4 <tu-email@gmail.com>
```

---

## 📚 Documentación Adicional

- `docs/PROJECT_PLAN.md` - Plan completo del proyecto
- `docs/ITERATION_0_PLAN.md` - Timeline día-por-día
- `docs/EXCEL_ANALYSIS.md` - Análisis del Excel fuente

---

## 🐛 Troubleshooting

### Error: "Database not found"

```bash
python database.py
```

### Error: "openpyxl not installed"

```bash
pip install -r requirements.txt
```

### No hay secciones en BD

```bash
python load_sections.py
```

### No hay tareas

```bash
python create_tasks_for_period.py --period 2025-11
```

---

## 📝 Notas de Desarrollo

### Decisiones Técnicas

1. **Periodicidad por tipo de tarea** (no por URL individual)
   - Simplifica configuración
   - Más fácil de mantener
   - Se puede cambiar desde pantalla Configuración

2. **Límite de 200 filas en Excel**
   - El Excel tiene 1M+ filas vacías
   - Optimización: solo leer primeras 200 filas
   - Suficiente para capturar las 173 URLs reales

3. **Task status: pending/ok/problem**
   - `pending`: No revisada aún
   - `ok`: Todo correcto
   - `problem`: Hay problemas (requiere observaciones)

### Bugs Conocidos

- (Ninguno por ahora)

---

## 👥 Autores

- **José Ramos** - Desarrollo
- **María García** - Requisitos y testing

---

**Última actualización**: 2025-10-28
**Próxima sesión**: Día 2 - Templates + Pantalla Principal