# Stage 3 Implementation Plan
## Automatización de 8 Tareas de Calidad Web

**Fecha de inicio**: 2025-10-31
**Timeline estimado**: 3-4 meses
**Presupuesto**: Solo herramientas gratuitas
**Objetivo**: Minimizar el trabajo manual en 173 URLs con 8 tipos de verificaciones

---

## 📋 Contexto del Proyecto

**Situación actual**:
- Tu esposa usa un Excel para marcar manualmente 8 tareas en 173 URLs
- Stage 1 (Manual): Sistema de gestión de tareas ✅
- Stage 2 (Crawler): Descubrimiento automático de URLs y enlaces rotos ✅ (~90% completado)

**Objetivo Stage 3**:
Automatizar las 8 tareas para que el sistema las ejecute y solo notifique cuando requieran atención humana.

**Tareas a automatizar**:
1. ✅ Enlaces rotos (~90% completado en Stage 2)
2. ✅ Enlaces incorrectos (~90% completado en Stage 2)
3. 🔲 Imágenes (alt text, tamaño, optimización, rotas)
4. 🔲 CTAs (call-to-action buttons)
5. 🔲 Textos - erratas (spelling/grammar)
6. 🔲 Información actualizada (content changes)
7. 🔲 FAQ (frequently asked questions)
8. 🔲 Diseño (accessibility, contrast, responsive)

---

## 🎯 Estrategia General

### Principios de Diseño
1. **Incremental**: Implementar tarea por tarea, no todas a la vez
2. **Validación temprana**: Probar cada tarea en 10-20 URLs antes de escalar a 173
3. **Notificación inteligente**: Solo alertar cuando haya problemas reales
4. **Falsos positivos mínimos**: Mejor no detectar algo que inundar con falsos positivos
5. **Portfolio-ready**: Código limpio, documentado, demostrable

### Arquitectura Propuesta
```
app.py (actual: 1,647 líneas)
    ↓
calidad/
    ├── __init__.py
    ├── enlaces.py         # Ya existe (Stage 2)
    ├── imagenes.py        # NUEVO - Phase 3.1
    ├── ctas.py            # NUEVO - Phase 3.2
    ├── textos.py          # NUEVO - Phase 3.3
    ├── contenido.py       # NUEVO - Phase 3.4
    ├── faq.py             # NUEVO - Phase 3.5
    ├── diseno.py          # NUEVO - Phase 3.6
    └── base.py            # Utilidades comunes

templates/calidad/
    ├── dashboard.html     # Dashboard unificado con 8 checks
    ├── imagenes.html
    ├── ctas.html
    ├── textos.html
    ├── contenido.html
    ├── faq.html
    └── diseno.html
```

---

## 📅 Fases de Implementación

### ✅ Phase 3.0: Preparación (ANTES de empezar)
**Duración estimada**: 1 semana
**Objetivo**: Refactorizar crawler existente y preparar arquitectura modular

**Tareas**:
- [ ] Mover lógica del crawler de `app.py` a `crawler/engine.py`
- [ ] Crear módulo base `calidad/base.py` con clase `QualityCheck`
- [ ] Actualizar base de datos con tabla `quality_checks`:
```sql
CREATE TABLE quality_checks (
    id SERIAL PRIMARY KEY,
    url_id INTEGER REFERENCES discovered_urls(id),
    check_type VARCHAR(50) NOT NULL, -- 'enlaces', 'imagenes', 'ctas', etc.
    status VARCHAR(20) NOT NULL,     -- 'pass', 'fail', 'warning', 'pending'
    severity VARCHAR(20),             -- 'critical', 'high', 'medium', 'low'
    details JSONB,                    -- Detalles específicos del check
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(url_id, check_type, checked_at)
);

CREATE INDEX idx_quality_checks_url ON quality_checks(url_id);
CREATE INDEX idx_quality_checks_type ON quality_checks(check_type);
CREATE INDEX idx_quality_checks_status ON quality_checks(status);
```

**Resultado esperado**:
- Código más modular y mantenible
- Base lista para agregar nuevos checks sin modificar crawler base
- Reducir `app.py` de 1,647 líneas a ~1,000 líneas

---

### 🔲 Phase 3.1: Verificación de Imágenes (PRIORIDAD 1)
**Duración estimada**: 2 semanas
**Valor para el usuario**: ⭐⭐⭐⭐⭐ (Muy alto - tarea muy repetitiva manualmente)

#### ¿Qué detectar?
1. **Imágenes rotas** (404, timeout)
2. **Imágenes sin alt text** (accesibilidad)
3. **Alt text vacío o genérico** ("image", "img123", etc.)
4. **Imágenes muy pesadas** (>500KB para web, >200KB para móvil)
5. **Imágenes sin lazy loading** (performance)
6. **Formatos no optimizados** (usar WebP cuando sea posible)
7. **Dimensiones incorrectas** (imagen 4000x3000 mostrada en 300x200)

#### Herramientas gratuitas
- **BeautifulSoup4** (ya instalado) - parsear `<img>` tags
- **Pillow** - analizar dimensiones, formato, tamaño
- **requests** - verificar si imagen carga correctamente
- **imagehash** (opcional) - detectar imágenes duplicadas

#### Implementación
```python
# calidad/imagenes.py
import requests
from PIL import Image
from io import BytesIO
from bs4 import BeautifulSoup

class ImageChecker:
    """Verificador de calidad de imágenes"""

    MAX_FILE_SIZE_WEB = 500 * 1024  # 500KB
    MAX_FILE_SIZE_MOBILE = 200 * 1024  # 200KB

    GENERIC_ALT_TEXTS = [
        'image', 'img', 'photo', 'picture',
        'imagen', 'foto', 'banner'
    ]

    def check_url(self, url, html_content):
        """Analiza todas las imágenes de una URL"""
        soup = BeautifulSoup(html_content, 'html.parser')
        images = soup.find_all('img')

        results = {
            'total_images': len(images),
            'issues': [],
            'warnings': [],
            'passed': []
        }

        for idx, img in enumerate(images):
            img_result = self._check_single_image(img, url, idx)

            if img_result['severity'] == 'critical':
                results['issues'].append(img_result)
            elif img_result['severity'] == 'warning':
                results['warnings'].append(img_result)
            else:
                results['passed'].append(img_result)

        return results

    def _check_single_image(self, img_tag, base_url, index):
        """Verifica una imagen individual"""
        src = img_tag.get('src', '')
        alt = img_tag.get('alt', '')
        loading = img_tag.get('loading', '')

        issues = []

        # 1. Verificar alt text
        if not alt:
            issues.append("Missing alt text (accessibility issue)")
        elif alt.lower().strip() in self.GENERIC_ALT_TEXTS:
            issues.append(f"Generic alt text: '{alt}'")

        # 2. Verificar lazy loading
        if loading != 'lazy' and index > 2:  # Las primeras 2-3 imágenes no necesitan lazy
            issues.append("Missing lazy loading attribute")

        # 3. Verificar si imagen carga
        if src:
            img_url = self._resolve_url(src, base_url)
            try:
                response = requests.get(img_url, timeout=5)
                if response.status_code != 200:
                    issues.append(f"Broken image: HTTP {response.status_code}")
                else:
                    # 4. Verificar tamaño del archivo
                    file_size = len(response.content)
                    if file_size > self.MAX_FILE_SIZE_WEB:
                        issues.append(f"Large file size: {file_size/1024:.0f}KB")

                    # 5. Verificar dimensiones vs display size
                    img_obj = Image.open(BytesIO(response.content))
                    width_attr = img_tag.get('width', '')
                    height_attr = img_tag.get('height', '')

                    if width_attr and height_attr:
                        display_w = int(width_attr.replace('px', ''))
                        display_h = int(height_attr.replace('px', ''))

                        # Si la imagen real es >2x el tamaño de display, está mal optimizada
                        if img_obj.width > display_w * 2 or img_obj.height > display_h * 2:
                            issues.append(
                                f"Over-sized: {img_obj.width}x{img_obj.height} "
                                f"displayed as {display_w}x{display_h}"
                            )

                    # 6. Verificar formato
                    if img_obj.format in ['PNG', 'BMP'] and file_size > 100*1024:
                        issues.append(f"Consider WebP format instead of {img_obj.format}")

            except requests.Timeout:
                issues.append("Image load timeout (>5s)")
            except Exception as e:
                issues.append(f"Error loading image: {str(e)}")
        else:
            issues.append("Missing src attribute")

        return {
            'src': src,
            'alt': alt,
            'issues': issues,
            'severity': 'critical' if any('broken' in i.lower() for i in issues) else 'warning' if issues else 'pass'
        }

    def _resolve_url(self, img_src, base_url):
        """Convierte URL relativa en absoluta"""
        from urllib.parse import urljoin
        return urljoin(base_url, img_src)
```

#### Base de datos
```sql
-- Agregar columna en discovered_urls
ALTER TABLE discovered_urls
ADD COLUMN image_check_status VARCHAR(20) DEFAULT 'pending',
ADD COLUMN image_issues JSONB;

-- O usar la tabla quality_checks (preferido)
INSERT INTO quality_checks (url_id, check_type, status, details)
VALUES (123, 'imagenes', 'fail', '{"broken": 2, "missing_alt": 5}'::jsonb);
```

#### UI - Dashboard de Imágenes
- **Vista resumen**: "X imágenes rotas, Y sin alt text, Z muy pesadas"
- **Vista detallada**: Lista de URLs con problemas de imágenes
- **Filtros**: Por tipo de issue, por severidad
- **Acciones**: "Marcar como revisado", "Ignorar warning"

#### Testing incremental
1. Probar en 10 URLs primero
2. Revisar falsos positivos manualmente
3. Ajustar umbrales (tamaños, alt text genéricos, etc.)
4. Escalar a 50 URLs
5. Finalmente a las 173 URLs

**Esfuerzo**: ⭐⭐⭐ (Medio - herramientas disponibles)
**Valor**: ⭐⭐⭐⭐⭐ (Muy alto - tarea muy manual actualmente)

---

### 🔲 Phase 3.2: Verificación de CTAs (PRIORIDAD 2)
**Duración estimada**: 1.5 semanas
**Valor para el usuario**: ⭐⭐⭐⭐ (Alto - crítico para conversión)

#### ¿Qué detectar?
1. **CTAs ausentes** en páginas importantes (homepage, servicios, contacto)
2. **CTAs rotos** (enlaces 404)
3. **CTAs ocultos** (display:none, visibility:hidden)
4. **CTAs con mal contraste** (texto no legible)
5. **CTAs sin texto descriptivo** ("Click aquí" vs "Solicitar cotización")
6. **CTAs duplicados** (mismo texto, mismo destino, múltiples veces)

#### Herramientas gratuitas
- **BeautifulSoup4** - parsear botones y enlaces
- **cssselect** o **lxml** - evaluar CSS de los elementos
- **Regex** - detectar patrones de texto en CTAs

#### Implementación
```python
# calidad/ctas.py
from bs4 import BeautifulSoup
import re

class CTAChecker:
    """Verificador de Call-to-Action buttons"""

    # Patrones de CTAs comunes
    CTA_PATTERNS = {
        'button_tags': ['button', 'a'],
        'button_classes': ['btn', 'button', 'cta', 'call-to-action'],
        'button_roles': ['button'],
    }

    # Textos genéricos que deben evitarse
    GENERIC_CTA_TEXTS = [
        'click aquí', 'click here', 'más', 'more',
        'leer más', 'read more', 'ver más', 'see more',
        'aquí', 'here'
    ]

    # URLs donde esperamos encontrar CTAs
    IMPORTANT_PAGES = [
        '/', '/home', '/index',
        '/servicios', '/services',
        '/contacto', '/contact',
        '/productos', '/products'
    ]

    def check_url(self, url, html_content):
        """Analiza CTAs en una URL"""
        soup = BeautifulSoup(html_content, 'html.parser')

        # Detectar todos los CTAs
        ctas = self._find_ctas(soup)

        results = {
            'total_ctas': len(ctas),
            'issues': [],
            'warnings': [],
            'passed': []
        }

        # Si es página importante y no tiene CTAs
        if self._is_important_page(url) and len(ctas) == 0:
            results['issues'].append({
                'type': 'missing_cta',
                'message': 'Important page has no CTAs',
                'severity': 'critical'
            })

        # Analizar cada CTA
        seen_ctas = {}
        for cta in ctas:
            cta_result = self._check_single_cta(cta)

            # Detectar duplicados
            cta_key = f"{cta_result['text']}|{cta_result['href']}"
            if cta_key in seen_ctas:
                cta_result['issues'].append('Duplicate CTA')
            seen_ctas[cta_key] = True

            if cta_result['severity'] == 'critical':
                results['issues'].append(cta_result)
            elif cta_result['severity'] == 'warning':
                results['warnings'].append(cta_result)
            else:
                results['passed'].append(cta_result)

        return results

    def _find_ctas(self, soup):
        """Encuentra todos los CTAs en el HTML"""
        ctas = []

        # Buscar por tags
        for tag in self.CTA_PATTERNS['button_tags']:
            elements = soup.find_all(tag)
            for el in elements:
                # Filtrar: debe ser botón o link prominente
                if self._looks_like_cta(el):
                    ctas.append(el)

        return ctas

    def _looks_like_cta(self, element):
        """Determina si un elemento parece un CTA"""
        # Verificar clases
        classes = element.get('class', [])
        for cls in classes:
            if any(pattern in cls.lower() for pattern in self.CTA_PATTERNS['button_classes']):
                return True

        # Verificar role
        if element.get('role') in self.CTA_PATTERNS['button_roles']:
            return True

        # Links con texto corto y llamativo (heurística)
        if element.name == 'a':
            text = element.get_text(strip=True)
            # CTAs típicos: 2-4 palabras, con verbos de acción
            words = text.split()
            if 2 <= len(words) <= 5:
                action_verbs = ['comprar', 'solicitar', 'descargar', 'ver', 'contactar',
                                'buy', 'request', 'download', 'view', 'contact']
                if any(verb in text.lower() for verb in action_verbs):
                    return True

        return False

    def _check_single_cta(self, cta):
        """Verifica un CTA individual"""
        text = cta.get_text(strip=True)
        href = cta.get('href', '')

        issues = []

        # 1. Verificar texto genérico
        if text.lower() in self.GENERIC_CTA_TEXTS:
            issues.append(f"Generic CTA text: '{text}'")

        # 2. Verificar que tenga destino
        if not href or href == '#':
            issues.append("CTA with no destination")

        # 3. Verificar si está oculto (CSS check - simplificado)
        style = cta.get('style', '')
        if 'display:none' in style or 'visibility:hidden' in style:
            issues.append("Hidden CTA")

        # 4. Verificar longitud del texto
        if len(text) < 3:
            issues.append(f"CTA text too short: '{text}'")

        return {
            'text': text,
            'href': href,
            'issues': issues,
            'severity': 'critical' if any('no destination' in i for i in issues) else 'warning' if issues else 'pass'
        }

    def _is_important_page(self, url):
        """Determina si la URL es una página importante"""
        from urllib.parse import urlparse
        path = urlparse(url).path.rstrip('/')
        return path in self.IMPORTANT_PAGES or path == ''
```

#### UI - Dashboard de CTAs
- **Vista resumen**: "X CTAs rotos, Y CTAs genéricos, Z páginas sin CTAs"
- **Vista por página**: Mostrar CTAs encontrados en cada página
- **Heatmap**: Páginas importantes vs número de CTAs

**Esfuerzo**: ⭐⭐⭐ (Medio - requiere heurísticas)
**Valor**: ⭐⭐⭐⭐ (Alto - impacta conversión)

---

### 🔲 Phase 3.3: Verificación de Textos y Erratas (PRIORIDAD 3)
**Duración estimada**: 2 semanas
**Valor para el usuario**: ⭐⭐⭐⭐ (Alto - profesionalismo)

#### ¿Qué detectar?
1. **Errores ortográficos** (typos)
2. **Errores gramaticales básicos**
3. **Texto en MAYÚSCULAS** (mala práctica)
4. **Texto muy largo sin párrafos** (legibilidad)
5. **Palabras repetidas** ("el el", "la la")
6. **Espacios múltiples** o caracteres raros

#### Herramientas gratuitas
- **language-tool-python** (LanguageTool API gratuita, 20 peticiones/minuto)
- **pyspellchecker** (offline, diccionario español/inglés)
- **Regex** - detectar patrones problemáticos

#### Implementación
```python
# calidad/textos.py
from spellchecker import SpellChecker
import re
from bs4 import BeautifulSoup

class TextChecker:
    """Verificador de calidad de textos"""

    def __init__(self, language='es'):
        self.spell = SpellChecker(language=language)

    def check_url(self, url, html_content):
        """Analiza el texto de una URL"""
        soup = BeautifulSoup(html_content, 'html.parser')

        # Extraer texto visible (excluir scripts, styles)
        for script in soup(['script', 'style', 'noscript']):
            script.decompose()

        text = soup.get_text(separator=' ', strip=True)

        results = {
            'total_words': len(text.split()),
            'issues': [],
            'warnings': []
        }

        # 1. Verificar ortografía
        misspelled = self._check_spelling(text)
        if misspelled:
            results['warnings'].append({
                'type': 'spelling',
                'count': len(misspelled),
                'examples': list(misspelled)[:10]  # Primeras 10
            })

        # 2. Verificar palabras repetidas
        repeated = self._find_repeated_words(text)
        if repeated:
            results['issues'].append({
                'type': 'repeated_words',
                'examples': repeated
            })

        # 3. Verificar texto en MAYÚSCULAS
        all_caps = self._find_all_caps_text(text)
        if all_caps:
            results['warnings'].append({
                'type': 'all_caps',
                'examples': all_caps
            })

        # 4. Verificar legibilidad
        readability_issues = self._check_readability(soup)
        if readability_issues:
            results['warnings'].extend(readability_issues)

        return results

    def _check_spelling(self, text):
        """Busca errores ortográficos"""
        words = re.findall(r'\b[a-záéíóúñ]+\b', text.lower())
        # Filtrar palabras comunes que no están en el diccionario (URLs, números, etc.)
        words = [w for w in words if len(w) > 3]

        misspelled = self.spell.unknown(words)
        return misspelled

    def _find_repeated_words(self, text):
        """Busca palabras consecutivas repetidas"""
        pattern = r'\b(\w+)\s+\1\b'
        matches = re.findall(pattern, text, re.IGNORECASE)
        return list(set(matches))

    def _find_all_caps_text(self, text):
        """Busca texto en MAYÚSCULAS (>5 palabras seguidas)"""
        sentences = text.split('.')
        all_caps = []

        for sentence in sentences:
            words = sentence.split()
            caps_words = [w for w in words if w.isupper() and len(w) > 3]
            if len(caps_words) >= 5:
                all_caps.append(' '.join(caps_words[:10]))

        return all_caps

    def _check_readability(self, soup):
        """Verifica problemas de legibilidad"""
        issues = []

        # Buscar párrafos muy largos (>500 palabras sin <br> o <p>)
        paragraphs = soup.find_all(['p', 'div'])
        for p in paragraphs:
            text = p.get_text(strip=True)
            word_count = len(text.split())

            if word_count > 500:
                issues.append({
                    'type': 'long_paragraph',
                    'word_count': word_count,
                    'excerpt': text[:100] + '...'
                })

        return issues
```

#### Limitaciones y decisiones
- **No usar GPT** (de pago): Usar LanguageTool API gratuita con rate limiting
- **Falsos positivos**: Nombres propios, términos técnicos - permitir "ignorar palabra"
- **Solo español**: Inicialmente solo ES, luego agregar EN si es necesario

**Esfuerzo**: ⭐⭐⭐⭐ (Alto - muchos falsos positivos a ajustar)
**Valor**: ⭐⭐⭐⭐ (Alto - profesionalismo)

---

### 🔲 Phase 3.4: Verificación de Información Actualizada (PRIORIDAD 4)
**Duración estimada**: 1 semana
**Valor para el usuario**: ⭐⭐⭐ (Medio - depende del sitio)

#### ¿Qué detectar?
1. **Fechas antiguas** en el texto (años pasados en copyright, "Actualizado en 2022", etc.)
2. **Cambios en el contenido** desde última revisión
3. **Links a contenido obsoleto** (referencias a productos discontinuados, etc.)
4. **Información contradictoria** entre páginas

#### Herramientas gratuitas
- **difflib** (Python built-in) - detectar cambios en texto
- **Regex** - buscar patrones de fechas
- **BeautifulSoup4** - extraer fechas y contenido

#### Implementación
```python
# calidad/contenido.py
import re
from datetime import datetime
from difflib import SequenceMatcher
from bs4 import BeautifulSoup

class ContentChecker:
    """Verificador de contenido actualizado"""

    def check_url(self, url, html_content, previous_content=None):
        """Analiza si el contenido está actualizado"""
        soup = BeautifulSoup(html_content, 'html.parser')
        text = soup.get_text(separator=' ', strip=True)

        results = {
            'issues': [],
            'warnings': []
        }

        # 1. Buscar fechas antiguas
        old_dates = self._find_old_dates(text)
        if old_dates:
            results['warnings'].append({
                'type': 'old_dates',
                'dates': old_dates
            })

        # 2. Detectar cambios desde última revisión
        if previous_content:
            changes = self._detect_changes(text, previous_content)
            if changes['similarity'] < 0.95:  # Si cambió más del 5%
                results['warnings'].append({
                    'type': 'content_changed',
                    'similarity': changes['similarity'],
                    'diff_preview': changes['preview']
                })

        return results

    def _find_old_dates(self, text):
        """Busca fechas antiguas (>2 años)"""
        current_year = datetime.now().year
        threshold_year = current_year - 2

        # Buscar años de 4 dígitos
        years = re.findall(r'\b(19|20)\d{2}\b', text)
        old_years = [y for y in years if int(y) < threshold_year]

        return list(set(old_years))

    def _detect_changes(self, current_text, previous_text):
        """Detecta cambios entre versiones de contenido"""
        similarity = SequenceMatcher(None, previous_text, current_text).ratio()

        # Generar preview de cambios (simplificado)
        if similarity < 0.95:
            preview = f"Content changed {(1-similarity)*100:.1f}%"
        else:
            preview = "No significant changes"

        return {
            'similarity': similarity,
            'preview': preview
        }
```

#### UI - Dashboard de Contenido
- **Vista resumen**: "X páginas con fechas antiguas, Y páginas con cambios"
- **Historial**: Mostrar cuándo cambió cada página por última vez
- **Diff visual**: Mostrar diferencias entre versión actual y anterior

**Esfuerzo**: ⭐⭐ (Bajo - relativamente simple)
**Valor**: ⭐⭐⭐ (Medio - útil pero no crítico)

---

### 🔲 Phase 3.5: Verificación de FAQ (PRIORIDAD 5)
**Duración estimada**: 1 semana
**Valor para el usuario**: ⭐⭐⭐ (Medio - depende si tienen FAQ)

#### ¿Qué detectar?
1. **FAQ sin estructura semántica** (sin `<details>`, `<summary>`, o schema markup)
2. **Preguntas sin respuestas**
3. **Respuestas muy cortas** (<20 palabras)
4. **FAQ desactualizado** (referencias a cosas obsoletas)
5. **FAQ no accesible** (no navegable con teclado)

#### Implementación
```python
# calidad/faq.py
from bs4 import BeautifulSoup

class FAQChecker:
    """Verificador de FAQ (Frequently Asked Questions)"""

    def check_url(self, url, html_content):
        """Analiza la calidad del FAQ"""
        soup = BeautifulSoup(html_content, 'html.parser')

        results = {
            'has_faq': False,
            'issues': [],
            'warnings': []
        }

        # Detectar si la página tiene FAQ
        faq_indicators = [
            soup.find('section', class_=re.compile('faq', re.I)),
            soup.find('div', id=re.compile('faq', re.I)),
            soup.find_all('details'),  # HTML5 FAQ structure
        ]

        if any(faq_indicators):
            results['has_faq'] = True

            # Verificar estructura semántica
            details_tags = soup.find_all('details')
            if not details_tags:
                results['warnings'].append({
                    'type': 'no_semantic_structure',
                    'message': 'FAQ without <details>/<summary> structure'
                })

            # Verificar schema markup (structured data para SEO)
            script_ld = soup.find('script', type='application/ld+json')
            if not script_ld or 'FAQPage' not in str(script_ld):
                results['warnings'].append({
                    'type': 'no_schema_markup',
                    'message': 'FAQ without FAQPage schema.org markup (SEO)'
                })

        return results
```

**Esfuerzo**: ⭐⭐ (Bajo)
**Valor**: ⭐⭐⭐ (Medio - solo si tienen FAQ)

---

### 🔲 Phase 3.6: Verificación de Diseño y Accesibilidad (PRIORIDAD 6)
**Duración estimada**: 2 semanas
**Valor para el usuario**: ⭐⭐⭐⭐ (Alto - legal y UX)

#### ¿Qué detectar?
1. **Contraste insuficiente** (WCAG AA compliance)
2. **Texto demasiado pequeño** (<16px)
3. **Links sin indicación de visitado**
4. **Formularios sin labels**
5. **Imágenes sin role o aria-label**
6. **Problemas responsive** (viewport, breakpoints)

#### Herramientas gratuitas
- **wcag-contrast-ratio** (Python) - calcular contraste de colores
- **BeautifulSoup4** - analizar estructura HTML
- **Lighthouse CLI** (opcional, via subprocess) - auditoría completa

#### Implementación (simplificada)
```python
# calidad/diseno.py
from bs4 import BeautifulSoup
import re

class DesignChecker:
    """Verificador de diseño y accesibilidad"""

    MIN_CONTRAST_RATIO = 4.5  # WCAG AA
    MIN_FONT_SIZE = 16

    def check_url(self, url, html_content):
        """Analiza accesibilidad y diseño"""
        soup = BeautifulSoup(html_content, 'html.parser')

        results = {
            'issues': [],
            'warnings': []
        }

        # 1. Verificar formularios sin labels
        forms = soup.find_all('form')
        for form in forms:
            inputs = form.find_all('input')
            for inp in inputs:
                if inp.get('type') not in ['submit', 'button', 'hidden']:
                    label = form.find('label', {'for': inp.get('id')})
                    if not label and not inp.get('aria-label'):
                        results['issues'].append({
                            'type': 'input_without_label',
                            'input_type': inp.get('type', 'text')
                        })

        # 2. Verificar viewport meta tag
        viewport = soup.find('meta', {'name': 'viewport'})
        if not viewport:
            results['warnings'].append({
                'type': 'missing_viewport',
                'message': 'No viewport meta tag (responsive issue)'
            })

        # 3. Verificar imágenes decorativas sin role
        images = soup.find_all('img')
        for img in images:
            alt = img.get('alt', '')
            role = img.get('role', '')

            if not alt and not role:
                results['warnings'].append({
                    'type': 'decorative_image_no_role',
                    'src': img.get('src', '')[:50]
                })

        return results
```

**Esfuerzo**: ⭐⭐⭐⭐ (Alto - muchos aspectos a verificar)
**Valor**: ⭐⭐⭐⭐ (Alto - cumplimiento legal WCAG)

---

## 📊 Dashboard Final (Stage 3 Completo)

### Vista Unificada de Calidad
```
╔══════════════════════════════════════════════════════════════╗
║              DASHBOARD DE CALIDAD WEB - 173 URLs            ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  📊 ESTADO GENERAL                    🕐 Última revisión:   ║
║  ✅ 156 URLs OK (90%)                    31/10/2025 14:35   ║
║  ⚠️  12 URLs con warnings (7%)                              ║
║  ❌ 5 URLs con issues críticos (3%)                         ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  🔍 VERIFICACIONES AUTOMÁTICAS (8)                           ║
║                                                              ║
║  1. 🔗 Enlaces             ✅ 98% OK   ❌ 3 rotos            ║
║  2. 🖼️  Imágenes            ⚠️  82% OK   ⚠️  12 sin alt      ║
║  3. 🎯 CTAs                ✅ 95% OK   ⚠️  2 genéricos       ║
║  4. 📝 Textos              ⚠️  88% OK   ⚠️  8 con erratas    ║
║  5. 🔄 Contenido           ✅ 100% OK  ✅ Todo actualizado  ║
║  6. ❓ FAQ                 ✅ 100% OK  ✅ Bien estructurado ║
║  7. 🎨 Diseño              ⚠️  90% OK   ⚠️  5 sin labels     ║
║  8. 📱 Responsive          ✅ 100% OK  ✅ Viewport OK       ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  🚨 ACCIONES REQUERIDAS                                      ║
║                                                              ║
║  • 3 enlaces rotos - [Ver detalles] [Crear tarea]          ║
║  • 12 imágenes sin alt text - [Revisar] [Asignar]          ║
║  • 8 páginas con erratas - [Corregir] [Ignorar]            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

### Flujo de Trabajo con Notificaciones
1. **Crawler ejecuta verificaciones** (programado diariamente a las 3 AM)
2. **Sistema genera resumen** de nuevos issues
3. **Email automático** solo si hay issues críticos o nuevos warnings
4. **Tu esposa revisa dashboard** cuando le llegue notificación
5. **Marca como "revisado"** o crea tarea manual si requiere acción humana

---

## 🛠️ Dependencias Nuevas

```txt
# requirements.txt - Agregar:
Pillow==10.4.0              # Phase 3.1 - Imágenes
imagehash==4.3.1            # Phase 3.1 - Duplicados (opcional)
pyspellchecker==0.8.1       # Phase 3.3 - Ortografía
wcag-contrast-ratio==0.9    # Phase 3.6 - Accesibilidad
```

**TOTAL**: 4 librerías nuevas (todas gratuitas, sin APIs externas)

---

## 📈 Cronograma Estimado (3-4 meses)

| Fase | Descripción | Duración | Fechas Aprox. |
|------|-------------|----------|---------------|
| **3.0** | Refactoring + arquitectura modular | 1 semana | 01-08 Nov |
| **MANTENIMIENTO** | Revisar código, optimizar | 2 días | 09-10 Nov |
| **3.1** | Verificación de Imágenes | 2 semanas | 11-24 Nov |
| **MANTENIMIENTO** | Revisar código, tests | 2 días | 25-26 Nov |
| **3.2** | Verificación de CTAs | 1.5 semanas | 27 Nov - 07 Dic |
| **MANTENIMIENTO** | Revisar código, tests | 2 días | 08-09 Dic |
| **3.3** | Verificación de Textos | 2 semanas | 10-23 Dic |
| **PAUSA NAVIDEÑA** | -- | 1 semana | 24-31 Dic |
| **MANTENIMIENTO** | Revisar código, tests | 2 días | 01-02 Ene |
| **3.4** | Verificación de Contenido | 1 semana | 03-09 Ene |
| **MANTENIMIENTO** | Revisar código, tests | 2 días | 10-11 Ene |
| **3.5** | Verificación de FAQ | 1 semana | 12-18 Ene |
| **MANTENIMIENTO** | Revisar código, tests | 2 días | 19-20 Ene |
| **3.6** | Verificación de Diseño | 2 semanas | 21 Ene - 03 Feb |
| **TESTING FINAL** | Testing integral, bugs | 1 semana | 04-10 Feb |
| **DOCUMENTACIÓN** | Portfolio, docs | 3 días | 11-13 Feb |

**TOTAL**: ~14 semanas = 3.5 meses

---

## 🎯 Criterios de Éxito

### Para tu esposa (usuario final)
- ✅ Reducir tiempo de revisión manual de **8 horas/semana → 1 hora/semana**
- ✅ Eliminar el Excel completamente
- ✅ Recibir solo notificaciones de issues reales (no falsos positivos)
- ✅ Dashboard claro y fácil de entender

### Para ti (desarrollador/portfolio)
- ✅ Código modular, mantenible, documentado
- ✅ Sistema escalable (fácil agregar más verificaciones)
- ✅ Zero downtime en producción
- ✅ Demo funcional para portfolio (screenshots, video)
- ✅ Arquitectura demostrable en entrevistas

### Métricas técnicas
- ✅ `app.py` < 1,000 líneas (actualmente 1,647)
- ✅ Cobertura de tests > 70%
- ✅ Tiempo de crawl completo < 30 minutos (173 URLs)
- ✅ Tasa de falsos positivos < 5%

---

## 🚫 Restricciones y No-Hacer

### NO implementar
- ❌ **Machine Learning** - Overkill para 173 URLs, no gratuito (compute)
- ❌ **Análisis de video/multimedia** - Fuera de scope
- ❌ **Análisis de performance detallado** (Lighthouse completo) - Demasiado lento
- ❌ **Integración con CMS** - No es objetivo actual
- ❌ **Multi-tenant** - Solo para una empresa por ahora
- ❌ **APIs de terceros de pago** - Solo herramientas gratuitas

### SÍ mantener
- ✅ **Simplicidad**: Soluciones simples antes que complejas
- ✅ **Incremental**: Una verificación a la vez
- ✅ **Testing real**: Probar en 10-20 URLs antes de escalar
- ✅ **Portfolio-ready**: Código limpio, commits descriptivos
- ✅ **Documentación continua**: README actualizado, comentarios útiles

---

## 📚 Recursos y Referencias

### Documentación técnica
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Schema.org FAQPage](https://schema.org/FAQPage)
- [Google's Web Vitals](https://web.dev/vitals/)

### Herramientas gratuitas usadas
- **BeautifulSoup4**: Web scraping
- **Pillow**: Procesamiento de imágenes
- **pyspellchecker**: Corrección ortográfica offline
- **LanguageTool API**: Gramática (rate limited gratis)
- **wcag-contrast-ratio**: Accesibilidad

### Alternativas evaluadas y descartadas
- ❌ **Selenium** - Demasiado lento para 173 URLs
- ❌ **Scrapy** - Overkill, preferimos simplicidad
- ❌ **GPT-4 API** - No es gratuito
- ❌ **AWS/GCP services** - No es gratuito

---

## 🔄 Estrategia de Rollback

Si una fase falla o genera demasiados falsos positivos:

1. **Desactivar verificación** en scheduler (flag en DB)
2. **Mantener código** pero no ejecutar automáticamente
3. **Permitir ejecución manual** para debugging
4. **Iterar** hasta reducir falsos positivos
5. **Reactivar** cuando esté listo

**No eliminar código** - siempre puede ser útil más adelante.

---

## ✅ Checklist de Inicio (Antes de Phase 3.0)

- [ ] Hacer backup de base de datos actual
- [ ] Crear branch `stage3-development`
- [ ] Actualizar `.claude/01-current-phase.md` con Phase 3.0
- [ ] Leer `MAINTENANCE_CHECKLIST.md` (próximo documento)
- [ ] Confirmar que Stage 2 está 100% funcional en producción
- [ ] Instalar dependencias nuevas (`pip install Pillow pyspellchecker`)
- [ ] Crear estructura de carpetas `calidad/`

---

**Documento creado**: 2025-10-31
**Última actualización**: 2025-10-31
**Autor**: Claude Code + Jesús Ramos
**Estado**: PLAN - Pendiente de aprobación

---

## 💬 Preguntas Frecuentes

**P: ¿Por qué no usar Selenium para JavaScript?**
R: La mayoría de las verificaciones (imágenes, textos, CTAs) no requieren JavaScript ejecutado. Si más adelante detectamos que hay contenido dinámico crítico, podemos agregar Playwright (más rápido que Selenium) solo para esas URLs específicas.

**P: ¿Qué pasa si hay demasiados falsos positivos?**
R: Cada verificación tiene un sistema de "ignorar" para palabras/elementos específicos. Además, el dashboard permite marcar issues como "falso positivo" para que no vuelvan a aparecer.

**P: ¿Cómo se integran estas verificaciones con el crawler existente?**
R: El crawler existente (Stage 2) descubre URLs y verifica enlaces. Las nuevas verificaciones (Stage 3) se ejecutan sobre las URLs ya descubiertas, como plugins modulares. No modifican el crawler base.

**P: ¿Esto reemplaza herramientas como Lighthouse/PageSpeed?**
R: No, esto es complementario. Lighthouse hace análisis muy profundos pero es lento (30s por página = 1.5 horas para 173 URLs). Nuestro sistema hace verificaciones más específicas y rápidas (~5-10s por página = 15-30 minutos total).

**P: ¿Qué pasa con el Excel actual?**
R: Una vez completado Stage 3, el Excel se vuelve obsoleto. Todas las verificaciones se hacen automáticamente y el sistema notifica solo cuando hay problemas. El trabajo manual se reduce de 8h/semana a ~1h/semana (solo revisar issues detectados).
