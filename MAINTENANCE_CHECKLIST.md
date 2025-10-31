# Maintenance Checklist
## Control de Crecimiento de Código y Calidad

**Propósito**: Evitar que "vibe coding" se convierta en "dead coding"
**Frecuencia**: Ejecutar DESPUÉS de cada fase de implementación (entre Phase 3.1, 3.2, 3.3, etc.)
**Tiempo estimado**: 2-3 horas por revisión

---

## 🎯 Filosofía de Mantenimiento

> **"El mejor código es el que no escribes"**

### Principios clave
1. **Eliminar antes que optimizar** - Código muerto es peor que código lento
2. **Simplificar antes que refactorizar** - Menos líneas = menos bugs
3. **Medir antes que asumir** - Datos > Intuición
4. **Documentar decisiones** - El "por qué" es más importante que el "cómo"

### Señales de alerta 🚨
- ❌ Funciones nunca usadas
- ❌ Código duplicado en 3+ lugares
- ❌ Archivos >500 líneas
- ❌ Funciones >50 líneas
- ❌ Imports no usados
- ❌ Comentarios desactualizados
- ❌ Tests que no fallan nunca (no están probando nada real)

---

## ✅ Checklist de Mantenimiento

### PARTE 1: Métricas de Código (15 minutos)

#### 1.1 Tamaño de archivos
```bash
# Ejecutar en terminal
find . -name "*.py" -type f ! -path "./venv/*" ! -path "./.venv/*" -exec wc -l {} + | sort -rn | head -20
```

**Criterios de evaluación**:
- [ ] ¿Hay archivos >500 líneas?
  - ✅ NO → Continuar
  - ❌ SÍ → **Planificar refactoring** (ver sección PARTE 3)

- [ ] ¿`app.py` tiene <1,000 líneas?
  - ✅ SÍ → Continuar
  - ❌ NO → **CRÍTICO**: Mover lógica a módulos

**Meta**: Ningún archivo >500 líneas, `app.py` <1,000 líneas

---

#### 1.2 Complejidad ciclomática
```bash
# Instalar radon si no está instalado
pip install radon

# Medir complejidad
radon cc . -a -nb --min C
```

**Criterios de evaluación**:
- [ ] ¿Hay funciones con complejidad ≥C (>10)?
  - ✅ NO → Continuar
  - ❌ SÍ → **Simplificar función** (extraer subfunciones)

**Meta**: Máxima complejidad B (6-10), idealmente A (1-5)

---

#### 1.3 Código duplicado
```bash
# Detectar código duplicado
pylint --disable=all --enable=duplicate-code .
```

**Criterios de evaluación**:
- [ ] ¿Hay bloques duplicados en 3+ archivos?
  - ✅ NO → Continuar
  - ❌ SÍ → **Extraer a utilidad común** en `calidad/base.py` o `utils.py`

**Meta**: Zero duplicación en 3+ lugares

---

#### 1.4 Imports no usados
```bash
# Detectar imports no usados
pip install autoflake
autoflake --check --remove-all-unused-imports -r .
```

**Criterios de evaluación**:
- [ ] ¿Hay imports no usados?
  - ✅ NO → Continuar
  - ❌ SÍ → **Eliminar automáticamente**:
```bash
autoflake --remove-all-unused-imports --in-place -r .
```

**Meta**: Zero imports no usados

---

#### 1.5 Funciones no usadas
```bash
# Detectar funciones que nunca se llaman
vulture . --min-confidence 80
```

**Criterios de evaluación**:
- [ ] ¿Hay funciones/variables que nunca se usan?
  - ✅ NO → Continuar
  - ❌ SÍ → **Eliminar o documentar por qué están** (futuro uso)

**Meta**: Zero código muerto (o justificar explícitamente)

---

### PARTE 2: Base de Datos (20 minutos)

#### 2.1 Revisar tamaño de base de datos
```bash
# Conectar a PostgreSQL y ejecutar
psql $DATABASE_URL -c "
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
    pg_total_relation_size(schemaname||'.'||tablename) AS size_bytes
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY size_bytes DESC;
"
```

**Criterios de evaluación**:
- [ ] ¿Hay tablas >100MB?
  - ✅ NO → Continuar
  - ❌ SÍ → **Considerar archivado/particionamiento**

- [ ] ¿`discovered_urls` tiene >10,000 filas?
  - ✅ NO → Continuar
  - ❌ SÍ → **Implementar limpieza de URLs antiguas** (>6 meses)

**Meta**: Tablas <100MB, `discovered_urls` <10K filas

---

#### 2.2 Verificar índices
```bash
# Listar índices
psql $DATABASE_URL -c "
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY tablename, indexname;
"
```

**Criterios de evaluación**:
- [ ] ¿Hay consultas lentas (>1s) sin índice?
  - ✅ NO → Continuar
  - ❌ SÍ → **Crear índice** en columnas WHERE/JOIN

- [ ] ¿Hay índices no usados?
  - ✅ NO → Continuar
  - ❌ SÍ → **Eliminar índice** (ocupan espacio)

**Meta**: Índices solo en columnas realmente consultadas

---

#### 2.3 Queries N+1
**Revisar manualmente** en código:

¿Hay loops que hacen consultas dentro?
```python
# ❌ MAL - N+1 query
for url in urls:
    details = cursor.execute("SELECT * FROM url_changes WHERE url_id = %s", (url['id'],))

# ✅ BIEN - 1 query
url_ids = [u['id'] for u in urls]
cursor.execute("SELECT * FROM url_changes WHERE url_id = ANY(%s)", (url_ids,))
```

**Criterios de evaluación**:
- [ ] ¿Hay loops con consultas SQL dentro?
  - ✅ NO → Continuar
  - ❌ SÍ → **Refactorizar a batch query**

**Meta**: Zero N+1 queries

---

### PARTE 3: Arquitectura y Diseño (30 minutos)

#### 3.1 Responsabilidades de archivos
**Revisar manualmente**:

¿Cada archivo tiene UNA responsabilidad clara?
- `app.py` → Solo rutas y configuración Flask
- `crawler/engine.py` → Solo lógica de crawling
- `calidad/imagenes.py` → Solo verificación de imágenes
- `db.py` → Solo conexiones y queries de base de datos

**Criterios de evaluación**:
- [ ] ¿Hay archivos que hacen "demasiado"?
  - ✅ NO → Continuar
  - ❌ SÍ → **Dividir en módulos** (Single Responsibility Principle)

**Señales de archivo "demasiado grande"**:
- >500 líneas
- >10 funciones diferentes
- Imports de >5 módulos diferentes
- Mezcla de lógica de negocio + presentación + datos

---

#### 3.2 Duplicación de lógica
**Buscar patrones repetidos**:

```bash
# Buscar código similar
grep -r "BeautifulSoup" --include="*.py" | wc -l
grep -r "requests.get" --include="*.py" | wc -l
grep -r "cursor.execute" --include="*.py" | wc -l
```

**Criterios de evaluación**:
- [ ] ¿La misma lógica se repite en 3+ archivos?
  - ✅ NO → Continuar
  - ❌ SÍ → **Extraer a `calidad/base.py` o `utils.py`**

**Ejemplo de extracción**:
```python
# Antes (repetido en imagenes.py, ctas.py, textos.py)
soup = BeautifulSoup(html_content, 'html.parser')
for script in soup(['script', 'style', 'noscript']):
    script.decompose()
text = soup.get_text(separator=' ', strip=True)

# Después (una vez en calidad/base.py)
def extract_clean_text(html_content):
    """Extrae texto limpio de HTML"""
    soup = BeautifulSoup(html_content, 'html.parser')
    for script in soup(['script', 'style', 'noscript']):
        script.decompose()
    return soup.get_text(separator=' ', strip=True)
```

---

#### 3.3 Jerarquía de dependencias
**Verificar que las dependencias van en una dirección**:

```
templates/
    ↓ (usa)
app.py
    ↓ (importa)
calidad/*.py
    ↓ (importa)
calidad/base.py
    ↓ (importa)
utils.py
```

**Reglas**:
- ❌ `utils.py` NO debe importar de `calidad/`
- ❌ `calidad/base.py` NO debe importar de `calidad/imagenes.py`
- ❌ `calidad/*.py` NO debe importar de `app.py`

**Criterios de evaluación**:
- [ ] ¿Hay dependencias circulares?
  - ✅ NO → Continuar
  - ❌ SÍ → **Refactorizar jerarquía**

---

### PARTE 4: Performance (30 minutos)

#### 4.1 Tiempo de crawl completo
```bash
# Ejecutar crawl de prueba y medir tiempo
time python -c "
from crawler.engine import run_crawl
import time
start = time.time()
run_crawl('https://example.com', max_depth=2, max_urls=50)
elapsed = time.time() - start
print(f'Tiempo: {elapsed:.1f}s para 50 URLs')
print(f'Proyección para 173 URLs: {elapsed * 173/50 / 60:.1f} minutos')
"
```

**Criterios de evaluación**:
- [ ] ¿Tiempo proyectado para 173 URLs <30 minutos?
  - ✅ SÍ → Continuar
  - ❌ NO → **Optimizar** (ver sección 4.3)

**Meta**: <30 minutos para crawl completo de 173 URLs

---

#### 4.2 Uso de memoria
```bash
# Monitorear memoria durante crawl
python -m memory_profiler crawler/engine.py
```

**Criterios de evaluación**:
- [ ] ¿Uso de memoria <512MB durante crawl?
  - ✅ SÍ → Continuar
  - ❌ NO → **Revisar leaks de memoria** (cerrar conexiones, liberar objetos grandes)

**Meta**: <512MB de RAM (compatible con plan gratuito de Render)

---

#### 4.3 Optimizaciones comunes

**Si el crawl es lento**, aplicar estas técnicas:

1. **Requests concurrentes** (usar `asyncio` o `concurrent.futures`)
```python
# Antes
for url in urls:
    response = requests.get(url)
    process(response)

# Después
from concurrent.futures import ThreadPoolExecutor
with ThreadPoolExecutor(max_workers=5) as executor:
    responses = executor.map(lambda u: requests.get(u, timeout=5), urls)
    for response in responses:
        process(response)
```

2. **Cache de HTML** (no re-crawlear si no cambió)
```python
# Guardar hash del contenido
content_hash = hashlib.md5(html_content.encode()).hexdigest()
if content_hash == previous_hash:
    print("No cambió, skip checks")
    return
```

3. **Rate limiting inteligente** (no esperar si servidor es rápido)
```python
# Ajustar delay según response time
if response.elapsed.total_seconds() < 0.5:
    time.sleep(0.1)  # Servidor rápido, poco delay
else:
    time.sleep(1.0)  # Servidor lento, más delay
```

---

### PARTE 5: Testing y Calidad (30 minutos)

#### 5.1 Cobertura de tests
```bash
# Ejecutar tests con cobertura
pytest --cov=. --cov-report=html
```

**Criterios de evaluación**:
- [ ] ¿Cobertura >70%?
  - ✅ SÍ → Continuar
  - ❌ NO → **Agregar tests** para funciones críticas

**Funciones críticas que DEBEN tener tests**:
- Verificadores de calidad (`calidad/*.py`)
- Parseo de HTML (extracción de imágenes, CTAs, etc.)
- Lógica de notificaciones (cuándo enviar email)
- Queries de base de datos complejas

**Meta**: >70% cobertura (no buscar 100%, es unrealistic)

---

#### 5.2 Tests que siempre pasan (falsos positivos)
**Revisar manualmente** cada test:

¿El test realmente valida algo?
```python
# ❌ MAL - Test que nunca falla
def test_images_checker():
    checker = ImageChecker()
    assert checker is not None  # Esto SIEMPRE pasa

# ✅ BIEN - Test con validación real
def test_images_checker_detects_missing_alt():
    html = '<img src="test.jpg">'  # Sin alt
    checker = ImageChecker()
    result = checker.check_url('http://test.com', html)
    assert len(result['issues']) > 0
    assert any('alt' in issue.lower() for issue in result['issues'])
```

**Criterios de evaluación**:
- [ ] ¿Todos los tests realmente validan comportamiento?
  - ✅ SÍ → Continuar
  - ❌ NO → **Mejorar tests** o eliminar tests inútiles

---

#### 5.3 Linting y formateo
```bash
# Verificar estilo de código
flake8 . --max-line-length=120 --exclude=venv,.venv,migrations

# Formatear código automáticamente
black . --line-length=120
```

**Criterios de evaluación**:
- [ ] ¿Código pasa linting sin errores?
  - ✅ SÍ → Continuar
  - ❌ NO → **Corregir errores** (o ajustar reglas si son demasiado estrictas)

**Meta**: Código consistente, fácil de leer

---

### PARTE 6: Seguridad (15 minutos)

#### 6.1 Secretos en código
```bash
# Buscar posibles secretos hardcodeados
grep -r "password\s*=" --include="*.py" .
grep -r "api_key\s*=" --include="*.py" .
grep -r "secret\s*=" --include="*.py" .
```

**Criterios de evaluación**:
- [ ] ¿Hay secretos hardcodeados?
  - ✅ NO → Continuar
  - ❌ SÍ → **Mover a variables de entorno** (.env)

**Meta**: Zero secretos en código

---

#### 6.2 SQL Injection
**Revisar queries manualmente**:

¿Todas las queries usan placeholders?
```python
# ❌ VULNERABLE
cursor.execute(f"SELECT * FROM users WHERE name = '{user_input}'")

# ✅ SEGURO
cursor.execute("SELECT * FROM users WHERE name = %s", (user_input,))
```

**Criterios de evaluación**:
- [ ] ¿Todas las queries usan placeholders (%s, %d)?
  - ✅ SÍ → Continuar
  - ❌ NO → **Refactorizar queries inmediatamente**

**Meta**: Zero SQL injection vulnerabilities

---

#### 6.3 XSS (Cross-Site Scripting)
**Revisar templates Jinja2**:

¿Usamos `{{ var }}` (escapado) o `{{ var|safe }}` (sin escapar)?
```jinja2
{# ✅ SEGURO - Jinja2 escapa automáticamente #}
<p>{{ user_input }}</p>

{# ❌ PELIGROSO - Solo si estás 100% seguro #}
<p>{{ user_input|safe }}</p>
```

**Criterios de evaluación**:
- [ ] ¿Evitamos `|safe` a menos que sea necesario?
  - ✅ SÍ → Continuar
  - ❌ NO → **Eliminar |safe** o validar input primero

**Meta**: Mínimo uso de `|safe`, siempre con validación previa

---

### PARTE 7: Documentación (15 minutos)

#### 7.1 README.md actualizado
**Verificar que README incluye**:
- [ ] Descripción del proyecto
- [ ] Instrucciones de instalación (`pip install -r requirements.txt`)
- [ ] Variables de entorno requeridas (`.env.example`)
- [ ] Cómo ejecutar la aplicación (`python app.py`)
- [ ] Cómo ejecutar tests (`pytest`)
- [ ] Screenshot del dashboard (si es portfolio)

---

#### 7.2 Docstrings en funciones
**Revisar que funciones complejas tienen docstrings**:
```python
# ✅ BIEN
def check_image_quality(url, html_content):
    """
    Verifica la calidad de todas las imágenes en una URL.

    Args:
        url (str): URL de la página a verificar
        html_content (str): HTML de la página

    Returns:
        dict: Diccionario con 'issues', 'warnings', 'passed'
    """
    pass
```

**Criterios de evaluación**:
- [ ] ¿Funciones complejas (>20 líneas) tienen docstrings?
  - ✅ SÍ → Continuar
  - ❌ NO → **Agregar docstrings**

**Meta**: Funciones >20 líneas con docstrings descriptivos

---

#### 7.3 Comentarios actualizados
**Buscar comentarios obsoletos**:
```bash
# Buscar TODOs antiguos
grep -r "TODO" --include="*.py" .
grep -r "FIXME" --include="*.py" .
grep -r "HACK" --include="*.py" .
```

**Criterios de evaluación**:
- [ ] ¿Hay TODOs/FIXMEs de hace >1 mes?
  - ✅ NO → Continuar
  - ❌ SÍ → **Resolver o eliminar** (si ya no aplica)

**Meta**: Comentarios siempre relevantes

---

### PARTE 8: Git y Versionado (10 minutos)

#### 8.1 Commits descriptivos
**Revisar últimos 10 commits**:
```bash
git log --oneline -10
```

**Criterios de evaluación**:
- [ ] ¿Commits tienen mensajes descriptivos?
  - ✅ SÍ (ej: "Add image quality checker with alt text validation")
  - ❌ NO (ej: "fix", "wip", "test")

**Buenas prácticas**:
- Usar prefijos: `feat:`, `fix:`, `refactor:`, `docs:`
- Mensaje en imperativo: "Add" no "Added"
- Máximo 72 caracteres en primera línea

---

#### 8.2 Branches limpias
```bash
# Listar branches
git branch -a
```

**Criterios de evaluación**:
- [ ] ¿Hay branches obsoletas (mergeadas hace >1 mes)?
  - ✅ NO → Continuar
  - ❌ SÍ → **Eliminar branches viejas**:
```bash
git branch -d branch-name
git push origin --delete branch-name
```

**Meta**: Solo branches activas (master, develop, feature-actual)

---

### PARTE 9: Decisiones y Trade-offs (15 minutos)

#### 9.1 Documentar decisiones técnicas
**Crear archivo `DECISIONS.md` si no existe**:

```markdown
# Decisiones Técnicas

## 2025-11-10: Por qué BeautifulSoup y no Scrapy
**Problema**: Necesitamos parsear HTML de 173 URLs
**Opciones consideradas**:
1. BeautifulSoup - Simple, síncrono
2. Scrapy - Framework completo, más complejo
**Decisión**: BeautifulSoup
**Razón**: Simplicidad > Performance para 173 URLs. Scrapy es overkill.
**Trade-off**: Si crecemos a >1000 URLs, reconsiderar Scrapy.

## 2025-11-15: Por qué no usar LanguageTool API para todo
**Problema**: Necesitamos detectar errores de ortografía/gramática
**Opciones consideradas**:
1. LanguageTool API (gratuita, rate limited)
2. pyspellchecker (offline, solo ortografía)
**Decisión**: pyspellchecker + LanguageTool API (opcional)
**Razón**: pyspellchecker es suficiente para 90% de casos, sin rate limits
**Trade-off**: Gramática avanzada requiere LanguageTool (usar solo si usuario lo pide)
```

**Criterios de evaluación**:
- [ ] ¿Documentamos decisiones importantes?
  - ✅ SÍ → Continuar
  - ❌ NO → **Crear `DECISIONS.md`** y agregar decisión actual

---

### PARTE 10: Reflexión y Planificación (15 minutos)

#### 10.1 ¿Qué funcionó bien?
**Escribir en `MAINTENANCE_LOG.md`**:
```markdown
# Maintenance Log

## 2025-11-10 - Post Phase 3.1 (Imágenes)

### ✅ Qué funcionó bien
- La arquitectura modular (`calidad/imagenes.py`) es fácil de mantener
- Tests cubrieron 85% del código nuevo
- Pillow es muy rápido para analizar imágenes

### ⚠️ Qué puede mejorar
- Algunos falsos positivos con imágenes SVG (tratar diferente)
- Queries a discovered_urls podrían optimizarse (agregar índice)
- Falta documentación en funciones de utilidad

### 🔧 Acciones tomadas
- [x] Agregado índice en discovered_urls.url
- [x] Agregado manejo especial para SVG
- [ ] Pendiente: Documentar funciones en calidad/base.py

### 📊 Métricas
- app.py: 1,200 líneas (era 1,647, reducido en refactoring)
- calidad/imagenes.py: 350 líneas
- Tiempo de crawl: 18 minutos para 173 URLs
- Cobertura de tests: 78%
```

---

#### 10.2 ¿Hay código que nunca se usó?
**Revisar funcionalidad**:

Después de 1 semana en producción, ¿se usó esta feature?
```bash
# Ver logs de uso
grep "image_quality_check" logs/app.log | wc -l
```

**Criterios de evaluación**:
- [ ] ¿Hay features que nadie usa después de 1-2 semanas?
  - ✅ NO → Continuar
  - ❌ SÍ → **Considerar eliminar** (o preguntar al usuario)

**Regla**: Si después de 1 mes nadie usa una feature, probablemente no la necesitan.

---

#### 10.3 Planificar siguiente fase
**Actualizar `.claude/01-current-phase.md`**:

```markdown
# Current Phase: Maintenance - Post Phase 3.1

## ✅ Completado
- [x] Phase 3.1: Verificación de Imágenes
- [x] Refactoring de crawler a módulo separado
- [x] Reducción de app.py de 1,647 → 1,200 líneas

## 📊 Estado Actual
- Base de datos: 3,450 URLs descubiertas
- Último crawl: 2025-11-10 14:30
- Issues encontrados: 12 imágenes sin alt, 3 imágenes rotas

## 🎯 Siguiente Fase: Phase 3.2 (CTAs)
- Fecha estimada de inicio: 2025-11-12
- Duración estimada: 1.5 semanas
- Dependencias: Ninguna (puede empezar ya)

## ⚠️ Pendientes antes de Phase 3.2
- [ ] Resolver issue #23: Falsos positivos con SVG
- [ ] Optimizar query en crawler/results (agregar índice)
- [ ] Actualizar README con screenshots de dashboard
```

---

## 📋 Resumen Ejecutivo (Copiar y pegar después de cada maintenance)

### Checklist Rápida (5 minutos)
- [ ] `app.py` <1,000 líneas
- [ ] Ningún archivo >500 líneas
- [ ] Zero imports no usados (ejecutar autoflake)
- [ ] Zero código duplicado en 3+ lugares
- [ ] Zero secretos hardcodeados
- [ ] Zero SQL injection vulnerabilities
- [ ] Cobertura de tests >70%
- [ ] Tiempo de crawl <30 minutos
- [ ] README actualizado
- [ ] DECISIONS.md con decisiones importantes
- [ ] `.claude/01-current-phase.md` actualizado

---

## 🚨 Decisión: ¿Refactorizar o Continuar?

### SI la respuesta a ALGUNA de estas preguntas es SÍ, hacer refactoring ANTES de continuar:
- [ ] ¿`app.py` >1,500 líneas?
- [ ] ¿Hay archivos >1,000 líneas?
- [ ] ¿Hay funciones con complejidad ciclomática >15?
- [ ] ¿Tiempo de crawl >45 minutos?
- [ ] ¿Hay vulnerabilidades de seguridad (SQL injection, XSS)?
- [ ] ¿Tests están fallando en producción?

### SI todas son NO, es seguro continuar con siguiente fase.

---

## 🎯 Objetivo Final de Maintenance

**Después de cada fase, el código debe estar**:
- ✅ Más simple que antes (menos líneas, menos complejidad)
- ✅ Más rápido que antes (mejor performance)
- ✅ Más seguro que antes (sin vulnerabilidades nuevas)
- ✅ Mejor documentado que antes
- ✅ Más fácil de entender para tu "yo del futuro"

**Si no cumple estos criterios, NO continuar con siguiente fase.**

---

## 📚 Herramientas Recomendadas

### Instalación única (ejecutar una vez)
```bash
pip install radon autoflake vulture flake8 black pytest pytest-cov memory-profiler
```

### Alias útiles para `.bashrc` o `.zshrc`
```bash
alias check-code="flake8 . --max-line-length=120 --exclude=venv,.venv"
alias format-code="black . --line-length=120"
alias clean-imports="autoflake --remove-all-unused-imports --in-place -r ."
alias find-dead-code="vulture . --min-confidence 80"
alias check-complexity="radon cc . -a -nb --min C"
alias test-coverage="pytest --cov=. --cov-report=html && open htmlcov/index.html"
```

---

## 🔄 Frecuencia de Ejecución

| Checklist | Frecuencia | Tiempo |
|-----------|------------|--------|
| **PARTE 1: Métricas** | Después de cada fase | 15 min |
| **PARTE 2: Base de Datos** | Después de cada fase | 20 min |
| **PARTE 3: Arquitectura** | Cada 2-3 fases | 30 min |
| **PARTE 4: Performance** | Cada 2-3 fases | 30 min |
| **PARTE 5: Testing** | Después de cada fase | 30 min |
| **PARTE 6: Seguridad** | Cada fase (crítico) | 15 min |
| **PARTE 7: Documentación** | Cada 2-3 fases | 15 min |
| **PARTE 8: Git** | Cada fase | 10 min |
| **PARTE 9: Decisiones** | Después de decisiones importantes | 15 min |
| **PARTE 10: Reflexión** | Después de cada fase | 15 min |

**Total tiempo por maintenance completo**: ~2-3 horas

---

## 💡 Filosofía Final

> "No escribas código que tu yo del futuro odie leer"
>
> "El mejor refactor es el que elimina código, no el que lo reorganiza"
>
> "Si no estás usando una feature después de 1 mes, probablemente no la necesitas"

**Mantén el código simple, limpio, y enfocado en resolver problemas reales.**

---

**Documento creado**: 2025-10-31
**Última actualización**: 2025-10-31
**Autor**: Claude Code + Jesús Ramos
**Propósito**: Controlar crecimiento de código entre fases de Stage 3
