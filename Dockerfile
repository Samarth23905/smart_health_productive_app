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

# Copy requirements from backend
COPY backend/requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Copy the entire backend code
COPY backend/ .

# Expose port 5000, 8000
EXPOSE 5000 8000

# Health check using curl (lightweight alternative to requests)
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
    CMD curl -f http://localhost:${PORT:-5000}/health || exit 1

# Run gunicorn with optimized settings for free tier
# -w 2: Reduced from 4 workers to 2 for memory efficiency
# --timeout 60: Increased timeout for database operations
# --max-requests 100: Restart workers periodically to prevent memory bloat
CMD gunicorn -w 2 -b 0.0.0.0:${PORT:-5000} --timeout 60 --max-requests 100 app:app
