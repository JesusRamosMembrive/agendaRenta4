# GEMINI.md - Project Context for agendaRenta4

## Project Overview

This project is a web-based task management system called "Agenda Renta4", designed for the quality control of websites. It allows users to track recurring checks on a list of URLs.

- **Backend:** Python with the Flask web framework.
- **Database:** The application uses SQLite for local development and is configured to use PostgreSQL for production deployments (as indicated by `psycopg2-binary` in `requirements.txt` and the `render.yaml` file). The database schema is defined and initialized in `database.py`.
- **Frontend:** The frontend is rendered using Jinja2 templates located in the `templates/` directory. Static assets like CSS and JavaScript are in the `static/` directory.
- **Deployment:** The application is set up for deployment on the Render platform, using `gunicorn` as the WSGI web server. The configuration is defined in `render.yaml`.

Key functionalities include user authentication, periodic task generation based on predefined types, task status tracking (pending, ok, problem), and email notifications for alerts.

## Building and Running

### 1. Environment Setup

The project uses a `.env` file for configuration. You can copy the example file and edit it:

```bash
cp .env.example .env
```

### 2. Installing Dependencies

To install the required Python packages, run:

```bash
pip install -r requirements.txt
```

### 3. Database Initialization

For local development, you can initialize the SQLite database with:

```bash
python database.py
```

This will create the `agendaRenta4.db` file and populate it with initial data.

### 4. Running the Application

To run the Flask development server, use:

```bash
python app.py
```

The application will be available at `http://localhost:5000`.

### 5. Utility Scripts

The project includes several scripts for managing data:

- `python load_sections.py`: Loads URLs from an Excel file into the database.
- `python create_tasks_for_period.py`: Generates tasks for a specific period.
- `python seed_users.py`: Populates the database with test users.

## Development Conventions

- **Code Style:** The Python code generally follows PEP 8 conventions.
- **Database:** While SQLite is used for local development, the production environment uses PostgreSQL. The `migrate_to_postgres.py` script suggests a way to move data.
- **Authentication:** User authentication is handled by Flask-Login.
- **Configuration:** Application settings are managed through environment variables loaded via `python-dotenv`.
- **Testing:** There are no dedicated test files in the current structure. Tests should be added to ensure code quality.
