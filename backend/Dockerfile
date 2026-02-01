# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies (if needed for psycopg2 and other packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Copy the entire backend code
COPY . .

# Expose port 5000 (Flask dev) or use 8000 (gunicorn on Render)
EXPOSE 5000 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health', timeout=5)" || exit 1

# Run gunicorn (Procfile: web: gunicorn -w 4 -b 0.0.0.0:$PORT app:app)
# On Render, PORT env var is set automatically; locally defaults to 5000
CMD gunicorn -w 4 -b 0.0.0.0:${PORT:-5000} app:app
