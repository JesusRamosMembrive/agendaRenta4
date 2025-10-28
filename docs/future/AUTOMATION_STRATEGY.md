# Estrategia de Automatización

**Fecha de creación**: 2025-10-28
**Estado**: Planificación futura (Stage 2/3)
**Versión**: 1.0

---

## 🎯 Propósito de este Documento

Este documento analiza **qué tareas del control de calidad web se pueden automatizar** y propone una estrategia híbrida (humano + máquina) para implementar en etapas futuras.

**Contexto**: Tu esposa revisa manualmente 8 aspectos del sitio web del banco:
1. Enlaces rotos
2. Enlaces incorrectos
3. Textos - erratas
4. Información actualizada
5. Preguntas frecuentes
6. CTAs (Call-to-Actions)
7. Imágenes
8. Diseño

**Pregunta**: ¿Cuáles de estos se pueden automatizar?

---

## 🤖 Análisis de Automatización

### Tareas Fácilmente Automatizables ✅

#### 1. Enlaces Rotos
**Qué detecta**: Links que devuelven error 404, 500, timeout, etc.

**Tecnología**:
```python
import requests
from bs4 import BeautifulSoup

def check_broken_links(url):
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')

    broken_links = []
    for link in soup.find_all('a', href=True):
        href = link['href']
        try:
            response = requests.get(href, timeout=5)
            if response.status_code >= 400:
                broken_links.append({
                    'url': href,
                    'status': response.status_code,
                    'text': link.text
                })
        except Exception as e:
            broken_links.append({
                'url': href,
                'error': str(e)
            })

    return broken_links
```

**Precisión**: ~95%
**Falsos positivos**: Rate limiting, firewall blocks, links que requieren auth
**Esfuerzo**: 1 día implementación
**Valor**: ⭐⭐⭐⭐⭐ (muy alto - encuentra problemas objetivos)

---

#### 2. Enlaces Incorrectos
**Qué detecta**:
- Links internos que apuntan a dominio externo
- Redirects sospechosos
- Links a páginas descontinuadas

**Tecnología**:
```python
def check_incorrect_links(url, valid_domains=['renta4.com']):
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')

    suspicious_links = []
    for link in soup.find_all('a', href=True):
        href = link['href']
        parsed = urlparse(href)

        # Check if internal link goes to external domain
        if is_internal_looking(link.text) and parsed.netloc not in valid_domains:
            suspicious_links.append({
                'url': href,
                'reason': 'Internal link to external domain',
                'text': link.text
            })

        # Check for redirects
        response = requests.get(href, allow_redirects=False)
        if response.is_redirect:
            suspicious_links.append({
                'url': href,
                'redirects_to': response.headers['Location'],
                'reason': 'Unexpected redirect'
            })

    return suspicious_links
```

**Precisión**: ~80%
**Falsos positivos**: Links legítimos a partners, CDNs
**Esfuerzo**: 1-2 días implementación
**Valor**: ⭐⭐⭐⭐ (alto - pero requiere configuración de reglas)

---

#### 3. Imágenes Rotas
**Qué detecta**:
- Imágenes que no cargan (404)
- Imágenes sin alt text
- Imágenes muy pesadas (>2MB)

**Tecnología**:
```python
def check_images(url):
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')

    image_issues = []
    for img in soup.find_all('img'):
        src = img.get('src')
        alt = img.get('alt')

        # Check if image loads
        try:
            response = requests.get(src, timeout=5)
            if response.status_code != 200:
                image_issues.append({
                    'src': src,
                    'issue': f'HTTP {response.status_code}'
                })

            # Check size
            size_mb = len(response.content) / (1024 * 1024)
            if size_mb > 2:
                image_issues.append({
                    'src': src,
                    'issue': f'Large file ({size_mb:.2f}MB)'
                })
        except Exception as e:
            image_issues.append({
                'src': src,
                'issue': f'Failed to load: {e}'
            })

        # Check alt text
        if not alt:
            image_issues.append({
                'src': src,
                'issue': 'Missing alt text (accessibility)'
            })

    return image_issues
```

**Precisión**: ~90%
**Falsos positivos**: Lazy-loaded images, images behind auth
**Esfuerzo**: 1 día implementación
**Valor**: ⭐⭐⭐⭐ (alto - accesibilidad + UX)

---

#### 4. Textos - Erratas (Parcialmente)
**Qué detecta**:
- Palabras mal escritas
- Errores ortográficos obvios
- Problemas gramaticales básicos

**Tecnología**:
```python
import language_tool_python

def check_spelling(url):
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')

    # Extract text content
    text = soup.get_text()

    # Check with LanguageTool
    tool = language_tool_python.LanguageTool('es')
    matches = tool.check(text)

    errors = []
    for match in matches:
        errors.append({
            'text': match.context,
            'suggestion': match.replacements[:3],
            'message': match.message,
            'offset': match.offset
        })

    return errors
```

**Precisión**: ~70%
**Falsos positivos**: Muchos términos técnicos/financieros no reconocidos
**Esfuerzo**: 1 día implementación + configurar diccionario custom
**Valor**: ⭐⭐⭐ (medio - muchos falsos positivos, humano debe validar)

**Limitaciones**:
- No entiende contexto financiero
- Requiere diccionario custom de términos bancarios
- No detecta errores semánticos (palabra correcta, contexto incorrecto)

---

### Tareas Difícilmente Automatizables ⚠️

#### 5. Información Actualizada
**Qué requiere**: Verificar que datos (tasas, fechas, promociones) están al día

**Por qué es difícil**:
- Requiere fuente de verdad (¿cuál es la tasa correcta?)
- Sin API del banco, no hay forma de validar automáticamente
- Requiere juicio humano: "¿Esta promoción ya expiró?"

**Posible automatización parcial**:
```python
# Detectar fechas pasadas en textos
def check_outdated_dates(url):
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')
    text = soup.get_text()

    # Find dates in text
    dates = extract_dates(text)  # regex or NLP
    today = datetime.now()

    old_dates = []
    for date in dates:
        if date < today - timedelta(days=180):  # 6 months old
            old_dates.append({
                'date': date,
                'context': get_surrounding_text(date, text)
            })

    return old_dates
```

**Precisión**: ~50% (muchos falsos positivos)
**Esfuerzo**: 2-3 días + alto mantenimiento
**Valor**: ⭐⭐ (bajo - humano tiene que validar casi todo)

**Recomendación**: Dejar 100% manual, no vale la pena automatizar.

---

#### 6. Preguntas Frecuentes (FAQs)
**Qué requiere**: Evaluar si FAQs son relevantes, actuales, y responden lo que usuarios preguntan

**Por qué es difícil**:
- Completamente subjetivo
- Requiere análisis de queries de usuarios (analytics)
- Requiere juicio sobre relevancia

**Posible automatización parcial**:
- Comparar con analytics: ¿estas FAQs coinciden con búsquedas reales?
- Requiere acceso a Google Analytics o sistema de búsqueda interno

**Precisión**: N/A (demasiado subjetivo)
**Esfuerzo**: 3-5 días + integración con analytics
**Valor**: ⭐ (muy bajo - ROI negativo)

**Recomendación**: Dejar 100% manual.

---

#### 7. CTAs (Call-to-Actions)
**Qué requiere**: Verificar que botones/links de acción funcionan y son efectivos

**Automatizable** ✅:
- Verificar que botón funciona (click test con Selenium)
- Verificar que link apunta a página correcta

**No automatizable** ❌:
- ¿Es el CTA persuasivo?
- ¿Está bien ubicado?
- ¿El texto es claro?

**Tecnología** (parcial):
```python
from selenium import webdriver

def check_ctas(url):
    driver = webdriver.Chrome()
    driver.get(url)

    cta_issues = []
    ctas = driver.find_elements_by_class_name('cta-button')

    for cta in ctas:
        try:
            cta.click()
            # Check if redirected to expected page
            if 'error' in driver.current_url or '404' in driver.title:
                cta_issues.append({
                    'text': cta.text,
                    'issue': 'Broken CTA link'
                })
            driver.back()
        except Exception as e:
            cta_issues.append({
                'text': cta.text,
                'issue': f'CTA not clickable: {e}'
            })

    driver.quit()
    return cta_issues
```

**Precisión**: ~85% (funcionalidad), 0% (efectividad)
**Esfuerzo**: 2 días implementación
**Valor**: ⭐⭐⭐ (medio - solo verifica funcionamiento técnico)

**Recomendación**: Automatizar verificación técnica, evaluación humana de efectividad.

---

#### 8. Diseño
**Qué requiere**: Verificar que página se ve bien, es responsive, no tiene errores visuales

**Automatizable** ✅ (parcialmente):
- **Visual regression testing**: Screenshots antes/después, detectar cambios inesperados
- **Responsive testing**: Verificar que página se ve bien en móvil/tablet/desktop

**No automatizable** ❌:
- ¿Se ve "bien"? (completamente subjetivo)
- ¿El diseño es atractivo? (requiere ojo humano)
- ¿Hay errores sutiles de alineación? (difícil de detectar)

**Tecnología** (visual regression):
```python
from playwright.sync_api import sync_playwright
import pixelmatch

def visual_regression_test(url, baseline_screenshot):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        # Take screenshots at different viewports
        viewports = [
            {'width': 1920, 'height': 1080},  # Desktop
            {'width': 768, 'height': 1024},   # Tablet
            {'width': 375, 'height': 667}     # Mobile
        ]

        issues = []
        for viewport in viewports:
            page.set_viewport_size(viewport)
            page.goto(url)
            screenshot = page.screenshot()

            # Compare with baseline
            diff = compare_images(baseline_screenshot, screenshot)
            if diff > 0.05:  # More than 5% difference
                issues.append({
                    'viewport': f"{viewport['width']}x{viewport['height']}",
                    'diff_percentage': diff * 100,
                    'issue': 'Visual changes detected'
                })

        browser.close()
        return issues
```

**Precisión**: ~75% (detecta cambios, no evalúa calidad)
**Esfuerzo**: 3-4 días implementación + setup baseline
**Valor**: ⭐⭐⭐ (medio - útil para detectar regresiones, no para evaluar diseño inicial)

**Recomendación**: Útil en Stage 3 para detectar cambios no intencionados, pero no reemplaza evaluación humana.

---

## 📊 Resumen: ¿Qué Automatizar?

| Tarea | Automatizable | Precisión | Esfuerzo | Valor | Prioridad |
|-------|---------------|-----------|----------|-------|-----------|
| **Enlaces rotos** | ✅ Sí | 95% | 1 día | ⭐⭐⭐⭐⭐ | **P0** (Alta) |
| **Imágenes rotas** | ✅ Sí | 90% | 1 día | ⭐⭐⭐⭐ | **P0** (Alta) |
| **Enlaces incorrectos** | ✅ Parcial | 80% | 2 días | ⭐⭐⭐⭐ | **P1** (Media) |
| **CTAs (funcionalidad)** | ✅ Parcial | 85% | 2 días | ⭐⭐⭐ | **P1** (Media) |
| **Erratas** | ⚠️ Parcial | 70% | 1 día | ⭐⭐⭐ | **P2** (Baja) |
| **Diseño (regresiones)** | ⚠️ Parcial | 75% | 4 días | ⭐⭐⭐ | **P2** (Baja) |
| **Información actualizada** | ❌ No | 50% | 3 días | ⭐⭐ | **P3** (No hacer) |
| **FAQs relevancia** | ❌ No | N/A | 5 días | ⭐ | **P3** (No hacer) |
| **CTAs (efectividad)** | ❌ No | 0% | N/A | ⭐ | **P3** (No hacer) |
| **Diseño (estética)** | ❌ No | 0% | N/A | ⭐ | **P3** (No hacer) |

**Conclusión**:
- ✅ **~40% automatizable** (enlaces, imágenes, CTAs técnicos)
- ⚠️ **~20% parcialmente** (erratas, diseño regresiones)
- ❌ **~40% requiere humano** (información, FAQs, efectividad, estética)

---

## 🎯 Estrategia: Enfoque Híbrido

### Stage 1: Task Manager Manual (Actual) ✅

**Objetivo**: Validar workflow y entender qué duele más

**Features**:
- Humano hace todas las revisiones (100% manual)
- Task manager solo organiza, trackea, registra historial
- Sin automatización

**Duración**: 1 mes uso real

**Métricas a recopilar**:
- ¿Qué encuentra MÁS frecuentemente? (enlaces rotos, erratas, info desactualizada?)
- ¿Qué tarea toma MÁS tiempo?
- ¿Qué secciones tienen MÁS problemas?

**Por qué empezar manual**:
1. Validar que task manager es útil antes de añadir complejidad
2. Recopilar datos reales para priorizar qué automatizar
3. Entender patrones (ej: siempre hay enlaces rotos en sección X)

---

### Stage 2: Task Manager + Escaneos Automáticos (Futuro) 🔮

**Objetivo**: Automatizar lo objetivo, humano valida y hace lo subjetivo

**Flujo propuesto**:

```
┌─────────────────────────────────────────┐
│  Scheduler (diario, 2am)                │
│                                          │
│  1. Check si toca activar tarea manual  │
│  2. Ejecutar escaneo automático         │
│     ├─ Enlaces rotos                    │
│     ├─ Imágenes rotas                   │
│     ├─ Enlaces incorrectos              │
│     └─ Spell check                      │
│                                          │
│  3. Guardar resultados en BD            │
│  4. Crear tarea con pre-report          │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│  Task Manager UI                        │
│                                          │
│  📋 Revisión: Renta Fija                │
│  Activada: 01/11/2025                   │
│                                          │
│  🤖 ESCANEO AUTOMÁTICO (01/11 2:05am):  │
│  ┌─────────────────────────────────┐    │
│  │ ❌ 3 enlaces rotos:              │    │
│  │   • /productos/bonos.html (404) │    │
│  │   • /fondos/detalle?id=123 (500)│    │
│  │   • external.com/page (timeout) │    │
│  │                                  │    │
│  │ ✅ 0 imágenes rotas              │    │
│  │                                  │    │
│  │ ⚠️ 2 posibles erratas:           │    │
│  │   • "interes" → "interés"       │    │
│  │   • "deposito" → "depósito"     │    │
│  │                                  │    │
│  │ [Ver detalles completos]        │    │
│  └─────────────────────────────────┘    │
│                                          │
│  ✋ REVISIÓN MANUAL:                     │
│  ☐ Validar enlaces rotos (reportados)   │
│  ☐ Validar erratas sugeridas            │
│  ☐ Información actualizada              │
│  ☐ Preguntas frecuentes                 │
│  ☐ CTAs efectivos                       │
│  ☐ Diseño se ve bien                    │
│                                          │
│  Observaciones:                          │
│  ┌─────────────────────────────────┐    │
│  │ Se corrigieron los 3 enlaces    │    │
│  │ rotos detectados. Solo 1 errata │    │
│  │ era real (interés).             │    │
│  └─────────────────────────────────┘    │
│                                          │
│  [Marcar como Realizada]                │
└─────────────────────────────────────────┘
```

**Benefits**:
- 🤖 Máquina encuentra problemas objetivos automáticamente
- 👤 Humano valida resultados automáticos + hace revisión subjetiva
- ⏱️ Ahorra tiempo: ya sabe qué enlaces revisar (no tiene que buscarlos)
- 📊 Métricas: tracking de falsos positivos, ajustar algoritmos

**Implementación**:

**Backend** (nuevo):
```python
# scanner.py - Web scanner module

import requests
from bs4 import BeautifulSoup
from datetime import datetime
from database import db

def scan_section(section_id):
    """
    Escanea una sección del sitio y detecta problemas automáticamente.
    """
    section = db.get_section(section_id)
    url = section['url']

    results = {
        'timestamp': datetime.now(),
        'section_id': section_id,
        'broken_links': check_broken_links(url),
        'broken_images': check_images(url),
        'spelling_errors': check_spelling(url),
        'suspicious_links': check_incorrect_links(url)
    }

    # Save results to DB
    db.save_scan_results(results)

    return results

# scheduler.py - Updated to include scanning

from apscheduler.schedulers.blocking import BlockingScheduler
from scanner import scan_section

def activate_tasks():
    """
    Revisa qué secciones toca activar y ejecuta escaneo automático.
    """
    sections_to_activate = get_sections_due_today()

    for section in sections_to_activate:
        # Run automated scan
        scan_results = scan_section(section['id'])

        # Create task with scan results pre-loaded
        task_id = create_task(section['id'])
        link_scan_to_task(task_id, scan_results)

        print(f"✓ Activated task for {section['name']} with automated scan")

scheduler = BlockingScheduler()
scheduler.add_job(activate_tasks, 'cron', hour=2)  # 2am daily
scheduler.start()
```

**Frontend** (actualizado):
```javascript
// Mostrar resultados de escaneo automático en UI

function renderTask(task) {
    const taskCard = document.createElement('div');
    taskCard.className = 'task-card';

    // Automated scan section
    if (task.scan_results) {
        const scanSection = `
            <div class="automated-scan">
                <h3>🤖 Escaneo Automático</h3>
                <p class="scan-time">Ejecutado: ${task.scan_results.timestamp}</p>

                ${renderBrokenLinks(task.scan_results.broken_links)}
                ${renderBrokenImages(task.scan_results.broken_images)}
                ${renderSpellingErrors(task.scan_results.spelling_errors)}

                <button onclick="viewFullReport(${task.id})">
                    Ver detalles completos
                </button>
            </div>
        `;
        taskCard.innerHTML += scanSection;
    }

    // Manual checklist section
    const manualSection = `
        <div class="manual-review">
            <h3>✋ Revisión Manual</h3>
            ${renderChecklist(task.checklist)}
            ${renderObservations(task.observations)}
        </div>
    `;
    taskCard.innerHTML += manualSection;

    return taskCard;
}
```

**Esfuerzo**: 3-5 días implementación
- Día 1: Web scanner básico (enlaces + imágenes)
- Día 2: Integración con scheduler y BD
- Día 3: UI para mostrar resultados automáticos
- Día 4-5: Spell check + refinar UX

---

### Stage 3: Automatización Avanzada (Futuro Lejano) 🚀

**Objetivo**: Máxima automatización, humano solo interviene cuando hay problemas

**Features avanzadas**:

**1. Escaneo continuo**
- Scanner corre cada noche (no solo cuando toca revisión manual)
- Detecta problemas en tiempo real
- Crea tareas solo si encuentra issues (no preventivas)

**2. Visual regression testing**
- Screenshots automáticos cada semana
- Detecta cambios visuales no intencionados
- Alerta si diseño se rompe

**3. SEO & Performance**
- Lighthouse scores automáticos
- Detectar páginas lentas
- Verificar meta tags, structured data

**4. Integración con analytics**
- Detectar páginas con alta tasa de rebote
- Priorizar revisión de páginas más visitadas
- Correlacionar problemas técnicos con métricas de negocio

**5. Dashboard de métricas**
```
┌──────────────────────────────────────────────────┐
│  AgendaRenta4 - Dashboard                        │
├──────────────────────────────────────────────────┤
│                                                   │
│  📊 Último Mes                                    │
│  ├─ 12 tareas completadas                        │
│  ├─ 47 enlaces rotos detectados → 45 corregidos  │
│  ├─ 23 erratas sugeridas → 8 aplicadas           │
│  └─ 3 imágenes rotas detectadas → 3 corregidas   │
│                                                   │
│  🎯 Efectividad del Scanner                       │
│  ├─ Enlaces rotos: 96% precisión (2% falsos pos.)│
│  ├─ Erratas: 35% precisión (muchos falsos pos.)  │
│  └─ Imágenes: 100% precisión                     │
│                                                   │
│  🔥 Secciones con Más Problemas                   │
│  1. Renta Fija (12 issues/mes)                   │
│  2. Fondos (8 issues/mes)                        │
│  3. Depósitos (5 issues/mes)                     │
│                                                   │
│  ⏰ Próximas Revisiones                           │
│  • Renta Fija - mañana                           │
│  • Fondos - en 3 días                            │
│  • Seguros - en 1 semana                         │
└──────────────────────────────────────────────────┘
```

**Esfuerzo**: 1-2 semanas implementación
**ROI**: Solo si el sistema se usa por >6 meses

---

## 🛠️ Stack Tecnológico (Stage 2)

### Web Scraping & Testing
- **requests** - HTTP requests para check links/images
- **Beautiful Soup** - Parse HTML y extract links/text
- **Selenium** o **Playwright** - Testing interactivo (CTAs, JavaScript)
- **LanguageTool** - Spell checking español
- **pixelmatch** - Visual regression testing

### Scheduler
- **APScheduler** - Escaneos programados
- **Celery** (opcional) - Si necesitamos queue/workers para escaneos pesados

### Storage
- Nueva tabla en SQLite:
```sql
CREATE TABLE scan_results (
    id INTEGER PRIMARY KEY,
    section_id INTEGER,
    timestamp DATETIME,
    broken_links JSON,
    broken_images JSON,
    spelling_errors JSON,
    other_issues JSON,
    FOREIGN KEY (section_id) REFERENCES sections(id)
);

CREATE TABLE task_scans (
    task_id INTEGER,
    scan_result_id INTEGER,
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    FOREIGN KEY (scan_result_id) REFERENCES scan_results(id)
);
```

---

## 📋 Plan de Implementación (Stage 2)

### Fase 1: Validación de Utilidad (1 mes)
**ANTES de implementar automatización:**

1. Usar Stage 1 (task manager manual) por 1 mes
2. Recopilar métricas:
   - ¿Qué problemas encuentra más frecuentemente?
   - ¿Cuánto tiempo toma cada tipo de revisión?
   - ¿Qué duele más?
3. Decidir si vale la pena automatizar

**Criterios para continuar a Stage 2**:
- ✅ Task manager es útil (se usa regularmente)
- ✅ >50% del tiempo se va en encontrar enlaces rotos/imágenes rotas
- ✅ Esposa dice "ojalá esto se detectara automáticamente"

---

### Fase 2: Implementación de Scanner Básico (Semana 1)

**Día 1-2: Enlaces rotos + Imágenes**
```bash
# Estructura de archivos
agendaRenta4/
├── backend/
│   ├── app.py (Flask app existente)
│   ├── scanner/
│   │   ├── __init__.py
│   │   ├── link_checker.py    # Check broken links
│   │   ├── image_checker.py   # Check broken images
│   │   └── utils.py
│   └── scheduler.py (actualizado)
├── tests/
│   └── test_scanner.py
└── requirements.txt (actualizado)
```

**Implementación**:
1. Módulo `link_checker.py` - detectar enlaces rotos
2. Módulo `image_checker.py` - detectar imágenes rotas
3. Unit tests básicos
4. Integrar con scheduler existente

**Output**: Scanner funcional que detecta enlaces/imágenes rotas

---

**Día 3: Integración con BD y Task Manager**
1. Tabla `scan_results` en BD
2. API endpoint: `GET /api/tasks/:id/scan-results`
3. Modificar task creation para incluir scan results
4. Testing end-to-end

**Output**: Scan results guardados y accesibles desde tasks

---

**Día 4-5: UI para Mostrar Resultados**
1. Componente de "Escaneo Automático" en task card
2. Lista de enlaces rotos con links clickables
3. Botón "Ver detalles completos" → modal con full report
4. Visual feedback (✅/❌/⚠️)

**Output**: Usuario ve resultados de escaneo en UI

---

### Fase 3: Validación de Precisión (Semana 2)

**Objetivo**: Medir falsos positivos y ajustar algoritmos

1. Usar scanner por 1 semana
2. Tu esposa valida cada resultado:
   - ¿Es realmente un link roto? (true positive)
   - ¿Falsa alarma? (false positive)
3. Calcular precision: `TP / (TP + FP)`
4. Ajustar thresholds y reglas

**Target**: >90% precisión para enlaces, >85% para imágenes

---

### Fase 4: Expansión (Semanas 3-4)

**Si Fase 3 es exitosa, añadir**:
- Spell checker (Day 1-2)
- Enlaces incorrectos (Day 3-4)
- CTAs funcionales con Selenium (Day 5-7)

**Si no, iterar**:
- Refinar algoritmos existentes
- Reducir falsos positivos
- Mejorar UX de resultados

---

## 🚫 Limitaciones y Consideraciones

### 1. Acceso al Sitio del Banco
**Problema**: Sitio puede requerir autenticación, VPN, o estar detrás de firewall.

**Solución**:
- Si público → scraping directo OK
- Si requiere login → guardar credenciales (Stage 3, con encryption)
- Si VPN → correr scanner desde máquina con acceso

### 2. Rate Limiting y Politeness
**Problema**: No queremos hacer DoS accidental al sitio del banco.

**Solución**:
```python
import time

def check_links_politely(links):
    results = []
    for link in links:
        response = requests.get(link)
        results.append(response)
        time.sleep(1)  # 1 segundo entre requests
    return results
```

**Best practices**:
- `User-Agent` identificable (no fingir ser browser normal)
- Respetar `robots.txt`
- Rate limit: max 1 request/segundo
- Correr en off-hours (2-4am)

### 3. Políticas de Seguridad del Banco
**Problema**: Puede que el banco no permita scraping automatizado.

**Solución**:
- **Opción A**: Pedir permiso interno (mejor)
- **Opción B**: Scraping "gentil" que no impacta performance
- **Opción C**: Solo automatizar en entorno de staging (no producción)

⚠️ **Importante**: Validar con IT del banco antes de implementar.

### 4. Mantenimiento de Selectores CSS
**Problema**: Si sitio cambia estructura HTML, scanner se rompe.

**Solución**:
- Usar selectores genéricos (`a[href]`, `img[src]`)
- Evitar selectores muy específicos (`.btn-primary-v2-deprecated`)
- Test suite para detectar cuando scanner falla

### 5. Falsos Positivos
**Problema**: Scanner reporta problemas que no son reales.

**Solución**:
- Whitelist de links conocidos (CDNs, partners)
- Configuración de timeouts apropiados
- Humano siempre valida antes de actuar
- Tracking de precision para ajustar algoritmos

---

## 💡 Recomendación Final

### Immediate (Stage 1 - Ahora)
✅ **Task manager manual** - Validar workflow primero
- Sin automatización
- Recopilar métricas de uso real

### Near Future (Stage 2 - 1-2 meses)
⏳ **Scanner básico** - Solo si Stage 1 es exitoso
- Enlaces rotos + imágenes (prioridad alta)
- Humano valida resultados
- Medir precisión y ajustar

### Far Future (Stage 3 - 6+ meses)
🔮 **Automatización avanzada** - Solo si Stage 2 demuestra ROI
- Visual regression
- SEO monitoring
- Dashboard de métricas
- Escaneo continuo

---

## 🎯 Criterios de Decisión

**¿Cuándo implementar Stage 2?**

Implementar automatización SI:
- ✅ Task manager se usa activamente por >1 mes
- ✅ >50% del tiempo se va en encontrar enlaces rotos
- ✅ Esposa encuentra >5 enlaces rotos por revisión
- ✅ Hay tiempo/recursos para mantener scanner

NO implementar SI:
- ❌ Task manager no se usa regularmente
- ❌ Problemas principales son subjetivos (info desactualizada)
- ❌ Pocas issues técnicas encontradas (<2 por revisión)
- ❌ No hay tiempo para mantenimiento

**Regla de oro**: Automatizar dolor real, no dolor imaginado.

---

## 📚 Recursos Técnicos

### Librerías Recomendadas
```txt
# requirements.txt (Stage 2 additions)

# Web scraping
requests==2.31.0
beautifulsoup4==4.12.2
lxml==4.9.3

# Spell checking
language-tool-python==2.7.1

# Browser automation (opcional)
playwright==1.40.0
selenium==4.15.2

# Scheduling
APScheduler==3.10.4

# Testing
pytest==7.4.3
responses==0.24.1  # Mock HTTP requests
```

### Ejemplos de Código Completos
Ver carpeta `docs/future/code-examples/` (crear en Stage 2):
- `link_checker_example.py`
- `image_checker_example.py`
- `spell_checker_example.py`
- `visual_regression_example.py`

### Herramientas Alternativas (SaaS)
Si no quieres desarrollar custom:
- **Broken Link Checker** (gratis, online)
- **Dead Link Checker** (gratis, online)
- **Screaming Frog SEO Spider** (app desktop, free tier)
- **Percy** (visual regression, $$ pero potente)
- **Checkly** (monitoring + testing, $$)

---

## 📝 Notas Finales

**Filosofía**:
> "Automatizar lo medible, humano para lo invaluable."

**Recordatorios**:
1. Automatización NO reemplaza juicio humano
2. Precisión < 100% → siempre validar
3. Implementar solo si dolor es real (medido)
4. Mantener simplicidad → complejidad solo si ROI claro

**Próximo paso**:
- Usar Stage 1 por 1 mes
- Revisar este documento después
- Decidir si Stage 2 aporta valor

---

**Documento creado**: 2025-10-28
**Autor**: Análisis conjunto (Jesús + Claude)
**Estado**: Planificación futura (no implementar todavía)
**Revisión**: Después de 1 mes uso de Stage 1