"""
Whitelist de términos permitidos para el spell checker.
Incluye marcas, términos financieros, técnicos y abreviaturas comunes.
"""

# Marcas y nombres propios
BRANDS = {
    'renta4', 'r4', 'renta', 'banco',
    'ibex', 'nasdaq', 'dow', 'jones',
    'microsoft', 'apple', 'google', 'amazon',
}

# Términos financieros
FINANCIAL_TERMS = {
    'etf', 'etfs', 'apalancamiento', 'bróker', 'broker',
    'trading', 'trader', 'forex', 'divisa', 'divisas',
    'acción', 'acciones', 'bono', 'bonos',
    'warrant', 'warrants', 'futuro', 'futuros',
    'opción', 'opciones', 'derivado', 'derivados',
    'cotización', 'cotizaciones', 'índice', 'índices',
    'cartera', 'carteras', 'portfolio', 'portfolios',
    'rentabilidad', 'volatilidad', 'liquidez',
    'capitalización', 'dividendo', 'dividendos',
    'benchmark', 'rating', 'hedge',
    'pip', 'pips', 'spread', 'swap',
    'scalping', 'hedging', 'apalancado',
    'bull', 'bullish', 'bear', 'bearish',
    'ipo', 'opa', 'opv',
    # Verbos y participios comunes financieros
    'obtenidos', 'obtenidas', 'obtenido', 'obtenida',
    'invertidos', 'invertidas', 'invertido', 'invertida',
    'adquiridos', 'adquiridas', 'adquirido', 'adquirida',
    'realizados', 'realizadas', 'realizado', 'realizada',
    'emitidos', 'emitidas', 'emitido', 'emitida',
    'cotizados', 'cotizadas', 'cotizado', 'cotizada',
    'negociados', 'negociadas', 'negociado', 'negociada',
    'reembolsados', 'reembolsadas', 'reembolsado', 'reembolsada',
    'suscritos', 'suscritas', 'suscrito', 'suscrita',
    # Sustantivos financieros adicionales
    'diversificación', 'amortización', 'plusvalías', 'minusvalías',
    'comisiones', 'subyacente', 'strike', 'vencimiento',
    # Términos de inversión
    'inversión', 'inversiones', 'inversionista', 'inversionistas',
    'rendimiento', 'rendimientos', 'renta', 'rentas',
    'mercado', 'mercados', 'evolución', 'variación', 'variaciones',
}

# Términos técnicos
TECHNICAL_TERMS = {
    'api', 'html', 'css', 'javascript', 'js',
    'url', 'urls', 'http', 'https',
    'seo', 'ui', 'ux', 'app', 'apps',
    'email', 'emails', 'web', 'online',
    'click', 'clicks', 'link', 'links',
    'pdf', 'excel', 'csv',
    'login', 'logout', 'username', 'password',
    'dashboard', 'backend', 'frontend',
    'responsive', 'mobile',
}

# Abreviaturas comunes
ABBREVIATIONS = {
    'etc', 'ej', 'sr', 'sra', 'sres', 'dra', 'dr',
    'ud', 'vd', 'uds', 'vds',
    'pág', 'págs', 'cap', 'vol',
    'cf', 'vs', 'sa', 'sl', 'slu',
    'iva', 'irpf', 'cnmv', 'bce', 'fed',
}

# Términos específicos de dominio
DOMAIN_SPECIFIC = {
    'webtrader', 'metatrader', 'ninjatrader',
    'bloomberg', 'reuters',
    'fintech', 'robo', 'advisor',
}

# Combinar todos los términos en un único set
WHITELIST_TERMS = (
    BRANDS |
    FINANCIAL_TERMS |
    TECHNICAL_TERMS |
    ABBREVIATIONS |
    DOMAIN_SPECIFIC
)

def is_whitelisted(word: str) -> bool:
    """
    Verifica si una palabra está en la whitelist.

    Args:
        word: Palabra a verificar (case-insensitive)

    Returns:
        True si la palabra está en la whitelist
    """
    return word.lower() in WHITELIST_TERMS


def add_custom_term(term: str) -> None:
    """
    Añade un término personalizado a la whitelist.

    Args:
        term: Término a añadir
    """
    WHITELIST_TERMS.add(term.lower())


def remove_custom_term(term: str) -> None:
    """
    Elimina un término de la whitelist.

    Args:
        term: Término a eliminar
    """
    WHITELIST_TERMS.discard(term.lower())
