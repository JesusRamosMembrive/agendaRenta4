# 🖼️ Verificación de Imágenes - Documentación

## ¿Qué hace este módulo?

El módulo de **Calidad de Imágenes** verifica que todas las imágenes de cada página web **se carguen correctamente** y no estén rotas.

---

## Sistema de Verificación (Simplificado)

Este check tiene un objetivo simple y claro:

### ✓ OK (Score: 100)
- Todas las imágenes de la página cargan correctamente
- No hay errores HTTP (404, 500, etc.)
- No hay timeouts al intentar cargar las imágenes

### ✗ Error (Score: 0)
- Una o más imágenes NO cargan
- Devuelven error HTTP (404, 403, 500, etc.)
- No responden (timeout)

---

## ¿Qué se verifica exactamente?

Para cada imagen en la página, se hace una petición HTTP HEAD para verificar:

1. **Status HTTP < 400** → Imagen funciona ✓
2. **Status HTTP ≥ 400** → Imagen rota ✗
3. **Timeout/Error** → Imagen rota ✗

---

## Detalles Reportados

Cuando hay imágenes rotas, el check guarda:
- URL de cada imagen rota
- Código de estado HTTP o tipo de error
- Total de imágenes analizadas

Ejemplo de resultado con errores:
```json
{
  "total_images": 23,
  "broken_images": 2,
  "broken_images_list": [
    {"url": "https://example.com/missing.jpg", "status": 404},
    {"url": "https://example.com/forbidden.png", "status": 403}
  ]
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
- `ignore_external`: Ignorar imágenes de dominios externos (por defecto: False)

---

## Por qué este diseño simple

Este sistema está optimizado para el caso de uso real:
- **Objetivo claro**: Detectar imágenes rotas
- **Fácil de entender**: 100 = OK, 0 = Hay problemas
- **Accionable**: Los detalles muestran exactamente qué imágenes arreglar

Otros aspectos como tamaño de archivo, formato (WebP vs JPG), o alt text para SEO son importantes pero quedan fuera del scope de este check enfocado en **funcionalidad básica**.
