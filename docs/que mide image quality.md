 Perfecto, ahora tengo toda la información necesaria. Déjame responderte con claridad:

  📊 ¿Qué mide el módulo de Calidad de Imágenes?

  El ImagenesChecker analiza 5 aspectos de calidad más allá de solo verificar si las imágenes cargan:

  1. Texto Alternativo (Alt Text) ❌ -10 puntos por imagen

  - Verifica si cada imagen tiene el atributo alt con contenido
  - Importante para SEO y accesibilidad
  - Se activa con: check_alt_text: True (activado por defecto)

  2. Tamaño de Archivo (File Size) 📦 -15 puntos por imagen

  - Detecta imágenes que pesan más de 1 MB
  - Afecta el rendimiento de carga de la página
  - Umbral configurable con: max_size_mb: 1.0

  3. Formato de Imagen (Format Optimization) 🎨 -5 puntos por imagen

  - Detecta imágenes en formatos antiguos (JPG, PNG, GIF)
  - Sugiere migración a formatos modernos como WebP
  - Se activa con: check_format: False (desactivado por defecto, pero lo activaste en las rutas)

  4. Imágenes Rotas (Broken Images) 🔴 -20 puntos por imagen

  - Verifica si la imagen devuelve 404 o error HTTP
  - El problema más crítico

  5. Errores de Red (Check Errors) ⚠️

  - Cuenta timeouts o errores de conexión al verificar imágenes
  - No penaliza el score pero se reporta en check_errors

  ---
  🎯 Sistema de Puntuación

  - Puntuación base: 100 puntos
  - Estado según score:
    - ok (verde): 100 puntos (sin problemas) o 0 imágenes
    - warning (amarillo): 70-99 puntos
    - error (rojo): 0-69 puntos

  ---
  🔄 ¿Cuándo se ejecutan los checks?

  NO se ejecutan automáticamente con el crawler ❌

  Actualmente, el crawler (crawler/crawler.py) solo:
  1. Descubre URLs
  2. Guarda enlaces rotos
  3. NO ejecuta checks de calidad de imágenes

  Se ejecutan SOLO manualmente ✅

  Los checks se ejecutan cuando:

  1. Manualmente desde la UI (botón 🖼️ en cada URL):
    - Página: "Configuración"
    - Ruta: /crawler/quality/check/<section_id> (POST)
  2. Batch manual (seleccionando múltiples URLs):
    - Página: "Configuración"
    - Botón: "Comprobar Seleccionadas"
    - Ruta: /crawler/quality/batch (POST)
  3. Consultando resultados:
    - Página: "🖼️ Calidad de Imágenes" (dashboard)
    - Ruta: /crawler/quality (GET)

  ---
  📝 Resumen de tu pregunta

  | Aspecto                                 | Respuesta                                                                            |
  |-----------------------------------------|--------------------------------------------------------------------------------------|
  | ¿Solo verifica carga de imágenes?       | No, verifica 5 aspectos: alt text, tamaño, formato, imágenes rotas, y errores de red |
  | ¿Se genera automáticamente con crawler? | NO - Solo se ejecuta manualmente desde la UI                                         |
  | ¿Cuándo se ejecuta?                     | Cuando haces clic en 🖼️ (individual) o "Comprobar Seleccionadas" (batch)            |

  ---
  ¿Te gustaría que el módulo de calidad de imágenes se ejecute automáticamente después de cada crawl? Puedo planificar esa integración si lo deseas.
