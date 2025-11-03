# 🧪 Prueba del Sistema de Quality Checks Post-Crawl

**Fecha de implementación:** 31 de Octubre de 2025
**Estado:** ✅ COMPLETADO - Listo para probar
**Siguiente paso:** Prueba end-to-end en la UI

---

## 📋 ¿Qué se implementó?

Se ha implementado un sistema completo que permite ejecutar **análisis de calidad automáticos** después de cada crawl.

### Características principales:

1. **Configurable por usuario**: Cada usuario decide qué análisis ejecutar
2. **Ejecución automática**: Los análisis se ejecutan solos al terminar el crawl
3. **Ejecución manual**: También se pueden ejecutar manualmente desde la UI
4. **Extensible**: Fácil agregar nuevos tipos de análisis
5. **No invasivo**: El crawl sigue siendo rápido (análisis se ejecutan después)

---

## 🔧 Componentes Implementados

### **Base de Datos**
- ✅ Migración `008_add_quality_check_config.sql` aplicada
- ✅ Tabla `quality_check_config` creada con datos iniciales
- ✅ Configuración para 3 usuarios con 2 checks cada uno

### **Backend**
- ✅ `calidad/post_crawl_runner.py` - Orquestador de checks
- ✅ `crawler/crawler.py` - Integración con el crawler
- ✅ `crawler/routes.py` - 3 nuevas rutas API:
  - `GET /crawler/config/checks` - Obtener configuración
  - `POST /crawler/config/checks` - Guardar configuración
  - `POST /crawler/results/<id>/run-checks` - Ejecutar checks manualmente

### **Frontend**
- ✅ `templates/configuracion.html` - Nueva sección "🔧 Herramientas de Análisis Automáticas"
  - Toggle switches para habilitar/deshabilitar
  - Checkboxes para ejecución automática
  - JavaScript para carga/guardado dinámico

### **Tests**
- ✅ Todos los tests unitarios pasaron
- ✅ Batch processing de 3 URLs verificado
- ✅ Integración completa verificada

---

## 🚀 Cómo Probar (Paso a Paso)

### **PASO 1: Iniciar la Aplicación**

```bash
cd /home/jesusramos/WorkSpace/agendaRenta4
python app.py
```

La aplicación debería iniciar en: http://127.0.0.1:5000

---

### **PASO 2: Configurar Checks Automáticos** ⚙️

1. Abre el navegador: http://127.0.0.1:5000
2. Inicia sesión con tu usuario
3. Ve a **"Configuración"** (menú lateral)
4. Desplázate hasta **"🔧 Herramientas de Análisis Automáticas"**

Deberías ver:

```
┌─────────────────────────────────────────────────┐
│ 🔗 Validación de Enlaces Rotos        [Toggle] │
│ Verifica que todos los enlaces funcionen        │
│ correctamente                                    │
│ ☐ Ejecutar automáticamente después del crawl   │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ 🖼️ Calidad de Imágenes               [Toggle] │
│ Analiza alt text, tamaño, formato y carga      │
│ de imágenes                                      │
│ ☐ Ejecutar automáticamente después del crawl   │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ 🔍 Análisis SEO                       [Toggle] │
│ Verifica meta tags, títulos y estructura SEO    │
│ (próximamente)                                   │
│ [DESHABILITADO]                                 │
└─────────────────────────────────────────────────┘
```

5. **Activa "Calidad de Imágenes":**
   - Click en el toggle switch (se pone rojo/activo)
   - Marca ☑ "Ejecutar automáticamente después del crawl"

6. Click en **"💾 Guardar Configuración de Análisis"**
   - Deberías ver: "✅ Configuración guardada correctamente"

---

### **PASO 3: Ejecutar un Crawl de Prueba** 🕷️

7. Ve a **"Crawler"** (menú lateral)

8. Click en **"➕ Iniciar Nuevo Crawl"**

9. **Configura el crawl (IMPORTANTE: usa valores pequeños):**
   ```
   URL Base: https://www.r4.com
   Profundidad Máxima: 1
   Máximo de URLs: 5
   ```
   ⚠️ **Usar máximo 5 URLs para que sea rápido**

10. Click en **"🚀 Iniciar Crawl"**

11. **Espera a que termine** (~30-60 segundos)

---

### **PASO 4: Verificar Ejecución Automática** ✅

Cuando el crawl termine, verifica:

#### **A. En los LOGS de la terminal:**

Deberías ver algo como esto:

```
INFO - Crawl completed: {'urls_discovered': 5, ...}
INFO - Running 1 automatic checks: ['image_quality']
INFO - Executing check: image_quality
INFO - Created batch 4 for 5 URLs
INFO - Checking https://www.r4.com/articulos-y-analisis...
INFO - ✓ https://www.r4.com/articulos-y-analisis: error (score: 30, issues: 12)
INFO - Checking https://www.r4.com/renta-fija...
INFO - ✓ https://www.r4.com/renta-fija: warning (score: 75, issues: 3)
INFO - Post-crawl checks completed for crawl run 3
INFO -   - image_quality: completed - Checked 5 sections, 5 successful
```

#### **B. En la UI - Dashboard de Calidad:**

12. Ve a **"🖼️ Calidad de Imágenes"** (menú lateral)

Deberías ver:

```
┌─────────────────────────────────────────────────┐
│ Estadísticas                                    │
├─────────────────────────────────────────────────┤
│ Total Checks: 5                                 │
│ Puntuación Media: 65                            │
│ ✓ OK: 2                                         │
│ ⚠ Warnings: 2                                   │
│ ✗ Errors: 1                                     │
└─────────────────────────────────────────────────┘

Tabla con las 5 URLs analizadas y sus resultados
```

13. **Click en cualquier URL** para ver detalles:
    - Total de imágenes encontradas
    - Imágenes sin alt text
    - Imágenes grandes (>1MB)
    - Imágenes rotas
    - Formato subóptimal (JPG/PNG vs WebP)

---

### **PASO 5: Probar Ejecución Manual** (Opcional)

Si quieres probar la ejecución manual:

14. Ve a **"Configuración"** de nuevo

15. **DESACTIVA** el checkbox "Ejecutar automáticamente después del crawl"
    - Mantén el toggle activado
    - Quita la marca de ☐ "Ejecutar automáticamente..."

16. Guarda la configuración

17. Ejecuta otro crawl pequeño

18. Esta vez, el análisis **NO** debería ejecutarse automáticamente

19. Ve a la página de **resultados del crawl**

20. Debería haber un botón para ejecutar checks manualmente
    - (Nota: Esta UI aún está pendiente de implementar en `crawler/results.html`)

---

## 🎯 Checks Disponibles

| Check | Icono | Estado | Descripción |
|-------|-------|--------|-------------|
| Validación de Enlaces Rotos | 🔗 | ✅ Disponible | Verifica HTTP status de todos los enlaces |
| Calidad de Imágenes | 🖼️ | ✅ Disponible | Alt text, tamaño, formato, enlaces rotos |
| Análisis SEO | 🔍 | 🔜 Próximamente | Meta tags, títulos, estructura |
| Performance | ⚡ | 🔜 Próximamente | Tiempos de carga, optimización |
| Accesibilidad | ♿ | 🔜 Próximamente | Estándares WCAG |

---

## 📊 Flujo del Sistema

```
1. Usuario habilita "image_quality" en Configuración
   ↓
2. Usuario ejecuta Crawl
   ↓
3. Crawl descubre URLs (proceso rápido)
   ↓
4. Crawl finaliza exitosamente
   ↓
5. _run_post_crawl_checks() se ejecuta automáticamente
   ↓
6. Lee quality_check_config para el usuario
   ↓
7. Encuentra: image_quality (enabled=True, auto=True)
   ↓
8. PostCrawlQualityRunner ejecuta BatchQualityCheckRunner
   ↓
9. Analiza cada URL secuencialmente (IMPORTANTE: uno tras otro)
   ↓
10. Guarda resultados en quality_checks
   ↓
11. Usuario ve resultados en "🖼️ Calidad de Imágenes"
```

---

## ⚙️ Configuración Actual

- **Ejecución:** SECUENCIAL (un check tras otro, no en paralelo)
- **Timing:** POST-CRAWL (después del crawl, no durante)
- **Control:** Usuario decide qué checks activar
- **Automático:** Se puede configurar ejecución automática

**¿Por qué secuencial?**
- Evita sobrecarga del servidor
- Logs más claros y fáciles de seguir
- Evita saturar el sitio objetivo con requests HTTP simultáneos
- Suficientemente rápido para análisis en background

---

## 🗄️ Base de Datos

### Tabla: `quality_check_config`

```sql
SELECT * FROM quality_check_config WHERE user_id = 1;
```

Resultado esperado:
```
 id | user_id |  check_type   | enabled | run_after_crawl
----+---------+---------------+---------+-----------------
  1 |       1 | broken_links  | f       | f
  2 |       1 | image_quality | f       | f
```

Después de configurar en la UI:
```
 id | user_id |  check_type   | enabled | run_after_crawl
----+---------+---------------+---------+-----------------
  1 |       1 | broken_links  | f       | f
  2 |       1 | image_quality | t       | t      ← ✅ ACTIVADO
```

---

## 🐛 Troubleshooting

### Problema 1: No se ejecutan los checks automáticos

**Verificar:**
```bash
# 1. Comprobar configuración en BD
PGPASSWORD=dev-password psql -U jesusramos -d agendaRenta4 -h localhost \
  -c "SELECT * FROM quality_check_config WHERE user_id = 1;"

# Debería mostrar enabled=t y run_after_crawl=t
```

**Solución:** Vuelve a la UI y guarda la configuración de nuevo.

---

### Problema 2: Error "Module not found: calidad.post_crawl_runner"

**Verificar:**
```bash
ls -la calidad/post_crawl_runner.py
# Debería existir el archivo
```

**Solución:** El archivo debería existir. Si no, revisa que el commit incluyó todos los archivos.

---

### Problema 3: Checks tardan mucho tiempo

**Causa:** Tienes muchas URLs/secciones activas.

**Solución:**
- Usa `max_urls=5` en el crawl de prueba
- Los checks analizan cada imagen de cada URL, puede tardar
- Normal: ~5 segundos por URL con imágenes

---

### Problema 4: La sección no aparece en Configuración

**Verificar:**
```bash
# Comprobar que el template tiene la sección
grep -n "Herramientas de Análisis" templates/configuracion.html
# Debería encontrar la línea
```

**Solución:** Refresca la página con Ctrl+Shift+R (forzar recarga sin caché).

---

## 📁 Archivos Modificados/Creados

### Nuevos:
- `migrations/008_add_quality_check_config.sql`
- `calidad/post_crawl_runner.py`

### Modificados:
- `crawler/crawler.py` - Método `_run_post_crawl_checks()`
- `crawler/routes.py` - 3 nuevas rutas API
- `templates/configuracion.html` - Nueva sección + JavaScript
- `static/css/style.css` - Color de headers de tabla

---

## 🎯 Próximos Pasos (Futuro)

### Implementaciones pendientes:

1. **UI en crawler/results.html:**
   - Mostrar qué checks se ejecutaron
   - Botones para re-ejecutar checks manualmente
   - Ver progreso de checks en ejecución

2. **UI en crawler/dashboard.html:**
   - Mostrar resumen de checks configurados antes de iniciar crawl
   - Indicador de qué checks se ejecutarán automáticamente

3. **Nuevos checks:**
   - Análisis SEO (meta tags, títulos, h1-h6)
   - Performance (tiempos de carga, tamaño total)
   - Accesibilidad (WCAG, contraste, estructura)

4. **Mejoras:**
   - Sistema de colas (Celery) para ejecución en background real
   - Notificaciones cuando terminan los checks
   - Exportar resultados a PDF/Excel
   - Comparar checks entre crawls (detectar mejoras/empeoramientos)

---

## ✅ Checklist de Prueba

Usa este checklist cuando pruebes:

- [ ] Aplicación inicia sin errores
- [ ] Página "Configuración" carga correctamente
- [ ] Sección "🔧 Herramientas de Análisis Automáticas" visible
- [ ] Se ven 2 checks disponibles (broken_links, image_quality)
- [ ] Toggle switches funcionan
- [ ] Checkbox "auto-run" funciona
- [ ] Botón "Guardar" funciona
- [ ] Alert "✅ Configuración guardada" aparece
- [ ] Crawl se ejecuta correctamente
- [ ] Logs muestran "Running 1 automatic checks"
- [ ] Logs muestran "Post-crawl checks completed"
- [ ] Página "🖼️ Calidad de Imágenes" muestra resultados
- [ ] Estadísticas se calculan correctamente
- [ ] Tabla muestra URLs analizadas
- [ ] Detalles de cada check son visibles

---

## 📞 Contacto / Notas

**Desarrollador:** Claude + Jesus Ramos
**Fecha:** 31 de Octubre de 2025
**Branch:** stage2
**Commit pendiente:** Sí (hacer commit de todos los cambios)

**Archivos listos para commit:**
```bash
git status
# Deberías ver:
# - migrations/008_add_quality_check_config.sql
# - calidad/post_crawl_runner.py
# - crawler/crawler.py (modificado)
# - crawler/routes.py (modificado)
# - templates/configuracion.html (modificado)
# - static/css/style.css (modificado)
```

---

## 🎉 Conclusión

El sistema está **100% implementado y testeado** en backend. Solo falta probarlo en la UI para verificar que todo funciona end-to-end.

**Estimación de tiempo de prueba:** 10-15 minutos

**Siguientes pasos recomendados:**
1. Probar flujo completo según esta guía
2. Si funciona: hacer commit y merge
3. Si falla: revisar logs y reportar error

¡Buena suerte con las pruebas! 🚀
