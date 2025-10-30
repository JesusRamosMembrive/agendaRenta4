# Repository Guidelines

## Project Structure & Module Organization
- `app.py` lanza la app Flask; los scripts de soporte (`database.py`, `load_sections.py`, `create_tasks_for_period.py`, `seed_users.py`, `manage_users.py`) se ejecutan desde la raíz.
- `templates/` y `static/` concentran la UI en Jinja; organiza nuevos assets por tipo (`css/`, `js/`, `img/`) y deja prototipos en `UI/`.
- `docs/` reúne la planificación vigente; revisa `docs/PROJECT_PLAN.md` y `ITERATION_0_PLAN.md` al abrir trabajo.
- `original-data/` almacena la fuente Excel y la base SQLite (`agendaRenta4.db`) se genera en la raíz; evita duplicados versionados.
- Configuración de despliegue vive en `render.yaml`, `build.sh`, `requirements.txt` y `runtime.txt` (Python 3.11.9).

## Build, Test, and Development Commands
- `pip install -r requirements.txt` instala dependencias.
- `python database.py` inicializa la base; admite subcomandos `stats`, `drop`, `seed`.
- `python load_sections.py` importa las 173 URLs desde el Excel base tras regenerar la BD.
- `python create_tasks_for_period.py --stats` comprueba la generación; añade `--period YYYY-MM` para validar meses concretos.
- `python app.py` levanta el servidor local en `http://localhost:5000`; `./build.sh` prueba el pipeline de Render.

## Coding Style & Naming Conventions
- Target Python 3.11; aplica PEP 8 con sangría de 4 espacios y docstrings breves en español.
- Usa snake_case para funciones, argumentos y archivos; reserva mayúsculas para constantes compartidas en `constants.py` o `utils.py`.
- Extiende las CLI con `argparse`, manteniendo nombres de flags cortos y consistentes (`--period`, `--stats`).
- Templates Jinja en snake_case (`inicio.html`) y assets servidos desde rutas relativas en `static/`.

## Testing Guidelines
- No hay suite automatizada; tras cambios ejecuta `python database.py stats` y, si aplica, `python create_tasks_for_period.py --period 2025-11 --quiet` para detectar duplicados.
- Al modificar vistas, arranca `python app.py` y revisa pantallas clave con datos reales de `agendaRenta4.db`.
- Registra en la PR las verificaciones manuales o scripts ad hoc; si añades pruebas, colócalas en `tests/` y ejecútalas con `pytest`.

## Commit & Pull Request Guidelines
- Mantén el formato histórico `Tipo: descripción` (`Fix:`, `Migrate:`, `Refactor:`) y mensajes en presente.
- Haz commits acotados e incluye en la descripción cualquier script o migración necesaria para reproducir el cambio.
- En la PR resume objetivo, comandos ejecutados y efectos en la BD; adjunta capturas si la UI cambia y vincula issues o planes en `docs/`.
- Verifica que `.env` siga ignorado y documenta variables nuevas en `.env.example`, junto con notas de despliegue en Render.
