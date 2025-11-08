#!/usr/bin/env python3
"""
Script para inspeccionar CTAs en páginas de ejemplo.
Analiza la estructura HTML y extrae posibles CTAs.
"""

import requests
from bs4 import BeautifulSoup
import json
from typing import List, Dict

# URLs a inspeccionar
URLS = [
    "https://www.r4.com/planes-de-pensiones/categorias",
    "https://www.r4.com/academiar4/formulario-cursos",
    "https://www.r4.com/conferencias",
    "https://www.r4.com/clientes",
    "https://www.r4.com/",
]

def extract_ctas(url: str) -> Dict:
    """Extrae posibles CTAs de una URL."""
    print(f"\n{'='*80}")
    print(f"Analizando: {url}")
    print(f"{'='*80}\n")

    try:
        response = requests.get(url, timeout=10, headers={
            'User-Agent': 'Mozilla/5.0 (compatible; AgendaRenta4/1.0; +http://example.com)'
        })
        response.raise_for_status()

        soup = BeautifulSoup(response.content, 'html.parser')

        results = {
            'url': url,
            'status_code': response.status_code,
            'ctas_found': []
        }

        # Estrategia 1: Buscar por clases comunes de botones/CTAs
        print("🔍 Buscando por clases CSS comunes...")
        common_cta_classes = [
            'btn', 'button', 'cta', 'call-to-action', 'boton',
            'btn-primary', 'btn-secondary', 'btn-cta',
            'link-cta', 'action-button'
        ]

        for class_name in common_cta_classes:
            elements = soup.find_all(class_=lambda x: x and class_name in x.lower() if x else False)
            for elem in elements:
                cta_info = extract_cta_info(elem, f"class::{class_name}")
                if cta_info:
                    results['ctas_found'].append(cta_info)

        # Estrategia 2: Buscar enlaces con texto específico
        print("🔍 Buscando enlaces con textos de CTA comunes...")
        cta_keywords = [
            'contratar', 'abrir cuenta', 'solicitar', 'saber más',
            'empezar', 'registr', 'inscrib', 'descargar',
            'contactar', 'llamar', 'consultar', 'invertir',
            'operar', 'comprar', 'vender', 'area cliente',
            'acceder', 'entrar'
        ]

        all_links = soup.find_all(['a', 'button'])
        for link in all_links:
            text = link.get_text(strip=True).lower()
            if any(keyword in text for keyword in cta_keywords):
                cta_info = extract_cta_info(link, "keyword_match")
                if cta_info:
                    results['ctas_found'].append(cta_info)

        # Estrategia 3: Buscar por roles ARIA
        print("🔍 Buscando por roles ARIA...")
        aria_elements = soup.find_all(attrs={'role': ['button', 'link']})
        for elem in aria_elements:
            cta_info = extract_cta_info(elem, "aria_role")
            if cta_info:
                results['ctas_found'].append(cta_info)

        # Eliminar duplicados
        results['ctas_found'] = deduplicate_ctas(results['ctas_found'])

        # Mostrar resultados
        print(f"\n📊 Total CTAs encontrados: {len(results['ctas_found'])}\n")
        for i, cta in enumerate(results['ctas_found'], 1):
            print(f"CTA #{i}:")
            print(f"  Texto: {cta['text']}")
            print(f"  URL: {cta['href']}")
            print(f"  Clases: {cta['classes']}")
            print(f"  Detectado por: {cta['detection_method']}")
            print(f"  Tag: {cta['tag']}")
            print()

        return results

    except Exception as e:
        print(f"❌ Error al analizar {url}: {e}")
        return {
            'url': url,
            'error': str(e),
            'ctas_found': []
        }

def extract_cta_info(element, detection_method: str) -> Dict:
    """Extrae información de un elemento CTA."""
    try:
        text = element.get_text(strip=True)
        if not text or len(text) > 100:  # Filtrar textos vacíos o muy largos
            return None

        href = element.get('href', '')
        classes = element.get('class', [])
        tag = element.name

        # Si es un botón sin href, buscar onclick o form parent
        if not href and tag == 'button':
            onclick = element.get('onclick', '')
            if onclick:
                href = f"onclick:{onclick[:50]}..."
            else:
                # Buscar si está dentro de un form
                form_parent = element.find_parent('form')
                if form_parent:
                    href = f"form_action:{form_parent.get('action', 'N/A')}"

        return {
            'text': text,
            'href': href,
            'classes': ' '.join(classes) if isinstance(classes, list) else classes,
            'tag': tag,
            'detection_method': detection_method
        }
    except Exception as e:
        return None

def deduplicate_ctas(ctas: List[Dict]) -> List[Dict]:
    """Elimina CTAs duplicados basándose en texto y href."""
    seen = set()
    unique_ctas = []

    for cta in ctas:
        key = (cta['text'].lower(), cta['href'])
        if key not in seen:
            seen.add(key)
            unique_ctas.append(cta)

    return unique_ctas

def main():
    """Analiza todas las URLs y genera un resumen."""
    all_results = []

    for url in URLS:
        result = extract_ctas(url)
        all_results.append(result)

    # Resumen final
    print("\n" + "="*80)
    print("📈 RESUMEN GENERAL")
    print("="*80 + "\n")

    total_ctas = sum(len(r['ctas_found']) for r in all_results)
    print(f"Total de URLs analizadas: {len(URLS)}")
    print(f"Total de CTAs encontrados: {total_ctas}")
    print(f"Promedio de CTAs por página: {total_ctas / len(URLS):.1f}")

    # Guardar resultados en JSON
    with open('cta_analysis_results.json', 'w', encoding='utf-8') as f:
        json.dump(all_results, f, indent=2, ensure_ascii=False)

    print("\n✅ Resultados guardados en: cta_analysis_results.json")

if __name__ == '__main__':
    main()
