# 🖼️ Verificación de Imágenes - Documentación

## ¿Qué hace este módulo?

El módulo de **Calidad de Imágenes** verifica que todas las imágenes de cada página web **se carguen correctamente** y no estén rotas.

---

## Sistema de Verificación

Este check tiene un objetivo simple y claro:

### ✓ OK (Score: 100)
- Todas las imágenes de la página cargan correctamente
- No hay errores HTTP (404, 500, etc.)
- No hay timeouts al intentar cargar las imágenes
- Imágenes con 403 (Forbidden) se reportan como **warnings** (no afectan el score)

### ⚠️ Warnings (No afectan score)
- Imágenes que devuelven **403 Forbidden** (protección contra hotlinking)
- Estas NO son errores reales, solo restricciones del servidor externo

### ✗ Error (Score: 0)
- Una o más imágenes NO cargan (404, 500, timeout, etc.)
- **NO incluye** imágenes con 403 (ver warnings arriba)

---

## ¿Qué se verifica exactamente?

Para cada imagen en la página, se hace una petición HTTP HEAD con headers realistas para verificar:

1. **Status HTTP < 400** → Imagen funciona ✓
2. **Status HTTP = 403** → Warning (hotlink protection) ⚠️
3. **Status HTTP ≥ 400 (excepto 403)** → Imagen rota ✗
4. **Timeout/Error** → Imagen rota ✗

**Nota**: Se envían headers `Referer` y `User-Agent` realistas para evitar falsos positivos.

---

## Detalles Reportados

El check guarda información detallada:
- Total de imágenes analizadas
- Imágenes rotas (errores reales)
- Imágenes con hotlink protection (warnings)
- Imágenes externas omitidas (si `ignore_external: true`)

Ejemplo de resultado:
```json
{
  "total_images": 21,
  "broken_images": 1,
  "broken_images_list": [
    {"url": "https://example.com/missing.jpg", "status": 404}
  ],
  "hotlink_protected": 4,
  "hotlink_protected_list": [
    {"url": "https://external.com/image.png", "status": 403, "note": "Hotlink protection (not a real error)"}
  ],
  "external_images_skipped": 5
}
```

---

## ¿Cuándo se ejecuta?

Los checks se ejecutan **automáticamente después de cada crawl** si tienes activada la opción en Configuración.

También puedes ejecutarlos manualmente:
1. **Individual**: Desde la página de Configuración, botón 🖼️ en cada URL
2. **Batch**: Seleccionando múltiples URLs y haciendo click en "Comprobar Seleccionadas"
3. **Ver resultados**: Página "🖼️ Calidad de Imágenes" (`/crawler/quality`)

---

## Configuración

Opciones disponibles:
- `timeout`: Tiempo máximo de espera (por defecto: 10 segundos)
- `ignore_external`: Ignorar imágenes de dominios externos (por defecto: **True**)

**Recomendación**: Mantener `ignore_external: True` para evitar falsos positivos por hotlink protection de sitios externos.

---

## Por qué este diseño simple

Este sistema está optimizado para el caso de uso real:
- **Objetivo claro**: Detectar imágenes rotas
- **Fácil de entender**: 100 = OK, 0 = Hay problemas
- **Accionable**: Los detalles muestran exactamente qué imágenes arreglar

Otros aspectos como tamaño de archivo, formato (WebP vs JPG), o alt text para SEO son importantes pero quedan fuera del scope de este check enfocado en **funcionalidad básica**.
