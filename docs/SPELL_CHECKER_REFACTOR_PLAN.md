# Plan de Refactorización: Corrector Ortográfico

**Fecha de creación**: 2025-11-04
**Autor**: Claude Code
**Prioridad**: Alta - Bloqueante para producción
**Estado**: Pendiente

---

## Resumen del Problema

El corrector ortográfico actual (`calidad/spell.py`) presenta dos problemas críticos:

1. **Falsos positivos**: Palabras válidas como "obtenidos", "inversión", etc. son marcadas como errores
2. **Extracción de texto incorrecta**: Incluye contenido de navegación, headers, footers y menús en el análisis, generando errores como "xRolling", "Cotizaciones", etc.

### Ejemplos de Problemas Detectados

**Falso Positivo**:
- ❌ Error detectado: "obtenidos"
- ✅ Oración: "...los rendimientos obtenidos pueden experimentar variaciones..."
- Diagnóstico: Palabra válida marcada como error

**Contenido Incorrecto**:
- ❌ Error detectado: "xRolling"
- Contexto: "Cotizaciones opciones Cotizaciones xRolling FX Simulador Warrants..."
- Diagnóstico: Está analizando el menú de navegación completo en lugar del contenido principal

---

## Plan de Refactorización

### FASE 1: Mejora de Extracción de Texto (Crítico)

#### [] 1.1. Implementar extracción semántica de contenido

**Objetivo**: Extraer solo el contenido principal de la página, excluyendo navegación y elementos estructurales.

**Archivo**: `calidad/spell.py` - función `_extract_text()` (línea 191)

**Cambios a realizar**:

```python
def _extract_text(self, html_content: str) -> str:
    """
    Extract main content text from HTML, excluding navigation and structural elements.
    """
    soup = BeautifulSoup(html_content, "html.parser")

    # 1. Remove non-content elements FIRST
    for tag in soup(['script', 'style', 'code', 'pre', 'kbd', 'var', 'samp',
                     'nav', 'header', 'footer', 'aside', 'menu']):
        tag.decompose()

    # 2. Try to find main content area (priority order)
    main_content = None

    # Option A: Look for <main> tag
    main_content = soup.find('main')

    # Option B: Look for <article> tags
    if not main_content:
        articles = soup.find_all('article')
        if articles:
            main_content = soup.new_tag('div')
            for article in articles:
                main_content.append(article)

    # Option C: Look for content divs (common patterns)
    if not main_content:
        main_content = soup.find('div', class_=['content', 'main-content', 'page-content'])

    # Option D: Fallback to body but exclude common non-content areas
    if not main_content:
        main_content = soup.find('body')
        if main_content:
            # Remove additional structural elements
            for tag in main_content.find_all(['nav', 'header', 'footer', 'aside']):
                tag.decompose()

    # 3. Extract text from selected content
    if main_content:
        text = main_content.get_text(separator=' ', strip=True)
    else:
        # Last resort: use all remaining text
        text = soup.get_text(separator=' ', strip=True)

    # 4. Clean up text
    text = re.sub(r'\s+', ' ', text)

    return text
```

**Testing**:
- [] Probar con URL: https://www.r4.com (página principal)
- [] Probar con URL: https://www.r4.com/fondos (página de fondos)
- [] Verificar que NO se incluyen elementos del menú
- [] Verificar que SÍ se incluye el contenido de párrafos

---

#### [] 1.2. Agregar logging para debugging

**Objetivo**: Poder ver qué texto está siendo analizado.

**Cambios**:

```python
def check(self, url: str, html_content: Optional[str] = None) -> Dict[str, Any]:
    # ... código existente ...

    text = self._extract_text(html_content)

    # LOG: Mostrar primeros 500 caracteres del texto extraído
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"[SPELL CHECK] URL: {url}")
    logger.info(f"[SPELL CHECK] Text preview (first 500 chars): {text[:500]}")
    logger.info(f"[SPELL CHECK] Total text length: {len(text)} characters")

    # ... resto del código ...
```

**Testing**:
- [] Verificar logs en consola durante ejecución
- [] Confirmar que el texto extraído es solo contenido relevante

---

### FASE 2: Mejora del Diccionario (Importante)

#### [] 2.1. Expandir whitelist con términos financieros

**Objetivo**: Reducir falsos positivos agregando términos válidos del dominio financiero.

**Archivo**: `calidad/whitelist_terms.py`

**Términos a agregar**:

```python
# Términos financieros comunes
FINANCIAL_TERMS = [
    # Verbos y participios comunes
    "obtenidos", "invertidos", "adquiridos", "realizados", "emitidos",
    "cotizados", "negociados", "reembolsados", "suscritos",

    # Sustantivos financieros
    "rentabilidad", "liquidez", "volatilidad", "diversificación",
    "amortización", "plusvalías", "minusvalías", "comisiones",

    # Términos de Renta 4
    "bróker", "warrants", "derivados", "subyacente", "strike",

    # Términos técnicos web (para evitar errores de navegación)
    "login", "logout", "trader", "dashboard", "portfolio"
]

# Actualizar WHITELIST_TERMS
WHITELIST_TERMS = set([
    # ... términos existentes ...
] + FINANCIAL_TERMS)
```

**Testing**:
- [] Verificar que "obtenidos" ya no se marca como error
- [] Verificar que "invertidos" ya no se marca como error
- [] Ejecutar test con 10 URLs aleatorias y revisar resultados

---

#### [] 2.2. Agregar diccionario personalizado de pyspellchecker

**Objetivo**: Enseñar al corrector palabras específicas del dominio.

**Archivo**: `calidad/spell.py` - función `__init__()`

**Cambios**:

```python
def __init__(self, config: Optional[Dict[str, Any]] = None):
    # ... código existente ...

    # Load custom dictionary
    from calidad.whitelist_terms import WHITELIST_TERMS

    # Add whitelist terms to spell checker
    self.spell = SpellChecker(language='es')
    self.spell.word_frequency.load_words(WHITELIST_TERMS)
```

**Testing**:
- [] Verificar que términos de WHITELIST_TERMS no generan errores
- [] Comparar cantidad de errores antes/después

---

### FASE 3: Optimización de Rendimiento (Opcional)

#### [] 3.1. Implementar caché de palabras verificadas

**Objetivo**: No verificar la misma palabra múltiples veces.

**Implementación**:

```python
class SpellChecker:
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        # ... código existente ...
        self._word_cache = {}  # {word: is_misspelled}

    def _is_misspelled(self, word: str) -> bool:
        """Check if word is misspelled, using cache."""
        if word in self._word_cache:
            return self._word_cache[word]

        result = word not in self.spell
        self._word_cache[word] = result
        return result
```

**Beneficio esperado**: ~20-30% mejora en velocidad

---

#### [] 3.2. Limitar sugerencias por palabra

**Objetivo**: No generar sugerencias costosas si no son necesarias.

**Cambios en `_check_spelling()`**:

```python
# Opción 1: No generar sugerencias (más rápido)
error = {
    "word": word,
    "position": match.start(),
    "context": self._get_context(text, match.start()),
    "suggestions": []  # Vacío para máxima velocidad
}

# Opción 2: Limitar a 3 sugerencias
suggestions = self.spell.candidates(word)
error = {
    "word": word,
    "position": match.start(),
    "context": self._get_context(text, match.start()),
    "suggestions": list(suggestions)[:3] if suggestions else []
}
```

**Beneficio esperado**: ~40-50% mejora en velocidad

---

### FASE 4: Evaluación de Alternativas (Futuro)

#### [] 4.1. Evaluar LanguageTool para español

**Objetivo**: Considerar un corrector más robusto y preciso.

**Biblioteca**: `language-tool-python`

**Pros**:
- Mucho mejor precisión para español
- Detecta errores gramaticales además de ortográficos
- Menos falsos positivos

**Contras**:
- Requiere instalar servidor LanguageTool (Java)
- Más lento que pyspellchecker
- Mayor consumo de memoria

**Investigación necesaria**:
- [] Instalar y probar con 20 URLs
- [] Medir tiempo de ejecución comparado
- [] Evaluar calidad de resultados
- [] Decidir si vale la pena el trade-off

**Documentación**: https://github.com/jxmorris12/language_tool_python

---

#### [] 4.2. Evaluar Hunspell como alternativa

**Objetivo**: Corrector C-based más rápido.

**Biblioteca**: `pyhunspell`

**Pros**:
- Muy rápido (implementación en C)
- Buena precisión
- Diccionarios de alta calidad

**Contras**:
- Requiere compilación de extensión C
- Más complejo de instalar

---

### FASE 5: Testing y Validación (Obligatorio)

#### [] 5.1. Crear dataset de prueba

**Archivo**: `tests/fixtures/spell_check_test_urls.json`

**Contenido**:

```json
{
  "urls": [
    {
      "url": "https://www.r4.com",
      "expected_errors": 0,
      "should_not_flag": ["obtenidos", "invertidos", "rentabilidad"]
    },
    {
      "url": "https://www.r4.com/fondos",
      "expected_errors": 0,
      "should_not_flag": ["diversificación", "liquidez"]
    }
  ]
}
```

---

#### [] 5.2. Crear test automatizado

**Archivo**: `tests/integration/test_spell_checker_quality.py`

```python
import pytest
from calidad.spell import SpellChecker

def test_no_false_positives_common_words():
    """Test that common financial terms are not flagged as errors."""
    checker = SpellChecker()

    text = "Los rendimientos obtenidos pueden experimentar variaciones"
    results = checker._check_spelling(text)

    # Should not flag "obtenidos"
    flagged_words = [error['word'] for error in results]
    assert 'obtenidos' not in flagged_words

def test_navigation_text_excluded():
    """Test that navigation menus are not included in analysis."""
    checker = SpellChecker()

    html = """
    <nav>
        <a href="#">xRolling</a>
        <a href="#">FakeMenuItem</a>
    </nav>
    <main>
        <p>Este es el contenido principal válido.</p>
    </main>
    """

    text = checker._extract_text(html)

    # Should NOT include navigation text
    assert 'xRolling' not in text
    assert 'FakeMenuItem' not in text

    # Should include main content
    assert 'contenido principal' in text
```

---

#### [] 5.3. Ejecutar regression testing

**Objetivo**: Asegurar que los cambios mejoran la calidad sin romper funcionalidad.

**Pasos**:
1. [] Ejecutar spell check en 117 URLs priority ANTES del refactor
2. [] Guardar resultados: `cp quality_checks_before.json`
3. [] Aplicar refactor
4. [] Ejecutar spell check en 117 URLs priority DESPUÉS del refactor
5. [] Guardar resultados: `cp quality_checks_after.json`
6. [] Comparar resultados:
   - Reducción de falsos positivos: esperado >80%
   - Reducción de errores de navegación: esperado 100%
   - Detección de errores reales: mantener >=95%

**Script de comparación**:

```bash
python scripts/compare_spell_check_results.py \
  --before quality_checks_before.json \
  --after quality_checks_after.json \
  --output comparison_report.md
```

---

### FASE 6: Documentación (Obligatorio antes de producción)

#### [] 6.1. Documentar cambios en spell.py

**Agregar docstring detallado**:

```python
"""
Spell Checker for Web Content

CHANGELOG:
- 2025-11-04: Improved text extraction to exclude navigation elements
- 2025-11-04: Expanded financial terms whitelist
- 2025-11-04: Added word-level caching for performance

KNOWN LIMITATIONS:
- Only checks Spanish language
- May flag technical terms not in dictionary
- Performance: ~5s per URL with 117 URLs

CONFIGURATION:
- max_text_length: 10000 characters (see constants.py)
- min_word_length: 4 characters
- Whitelist: calidad/whitelist_terms.py
"""
```

---

#### [] 6.2. Crear guía de uso para equipo

**Archivo**: `docs/SPELL_CHECKER_USAGE.md`

**Contenido**:
- Cómo ejecutar el spell checker manualmente
- Cómo agregar palabras a la whitelist
- Cómo interpretar los resultados
- Qué hacer si aparecen falsos positivos

---

### FASE 7: Deployment (Solo después de validación completa)

#### [] 7.1. Crear migration para limpiar datos antiguos

**Archivo**: `migrations/008_clean_spell_check_data.sql`

```sql
-- Limpiar resultados del spell checker antiguo
DELETE FROM quality_checks
WHERE check_type = 'spell_check'
  AND checked_at < '2025-11-04';  -- Fecha del refactor
```

---

#### [] 7.2. Actualizar configuración de herramientas

**En interfaz web**:
- [] Desactivar "Ejecutar automáticamente" para spell_check
- [] Agregar nota: "⚠️ Spell check está en fase de prueba"

---

#### [] 7.3. Deploy a staging

**Pasos**:
1. [] Push a rama `spell-checker-refactor`
2. [] Deploy a entorno de staging
3. [] Ejecutar spell check en 50 URLs
4. [] Revisar resultados manualmente
5. [] Si OK → Merge a stage-4
6. [] Si NO OK → Volver a FASE 1

---

#### [] 7.4. Deploy a producción

**Solo después de**:
- [] Todos los tests pasan
- [] Reducción de falsos positivos confirmada (>80%)
- [] Sin errores en staging durante 48h
- [] Aprobación del equipo

---

## Métricas de Éxito

### Antes del Refactor (Baseline)
- ❌ Falsos positivos: ~60-80% de errores detectados
- ❌ Errores de navegación: Presente en 100% de URLs
- ⏱️ Velocidad: ~10 min para 117 URLs

### Después del Refactor (Target)
- ✅ Falsos positivos: <10% de errores detectados
- ✅ Errores de navegación: 0%
- ⏱️ Velocidad: <8 min para 117 URLs (mejora esperada con caché)

---

## Estimación de Tiempo

| Fase | Tiempo estimado | Prioridad |
|------|----------------|-----------|
| FASE 1: Extracción de texto | 2-3 horas | 🔴 Crítica |
| FASE 2: Diccionario | 1-2 horas | 🔴 Crítica |
| FASE 3: Performance | 1-2 horas | 🟡 Opcional |
| FASE 4: Alternativas | 4-6 horas | 🟢 Futuro |
| FASE 5: Testing | 2-3 horas | 🔴 Crítica |
| FASE 6: Documentación | 1 hora | 🔴 Crítica |
| FASE 7: Deployment | 1-2 horas | 🔴 Crítica |
| **TOTAL MÍNIMO (sin FASE 3 y 4)** | **7-11 horas** | |
| **TOTAL COMPLETO** | **12-19 horas** | |

---

## Próximos Pasos Inmediatos

1. [] Comenzar con FASE 1.1 (extracción de texto)
2. [] Ejecutar test manual con 5 URLs
3. [] Si mejora visible → Continuar con FASE 1.2
4. [] Si no mejora → Revisar estrategia de extracción

---

## Notas Adicionales

### Alternativas Consideradas

**Opción A: Deshabilitar spell checker temporalmente**
- ✅ Desbloquea deployment rápido
- ❌ Pierde funcionalidad
- Recomendado: Solo si refactor toma >2 semanas

**Opción B: Hacer spell checker opcional/manual**
- ✅ Usuario decide cuándo usar
- ✅ No bloquea otros features
- Recomendado: Sí, como configuración adicional

**Opción C: Implementar como feature flag**
- ✅ Permite A/B testing
- ✅ Fácil rollback
- Recomendado: Sí, si el proyecto crece

---

## Referencias

- Documentación pyspellchecker: https://github.com/barrust/pyspellchecker
- BeautifulSoup text extraction: https://www.crummy.com/software/BeautifulSoup/bs4/doc/#get-text
- LanguageTool: https://languagetool.org/dev
- Hunspell dictionaries: https://github.com/LibreOffice/dictionaries

---

**Autor**: Claude Code
**Última actualización**: 2025-11-04
**Estado**: Plan aprobado, pendiente de ejecución
