#!/bin/bash

# Startup script for Azure App Service

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Apply database migrations (if using Alembic - add when ready)
# alembic upgrade head

# Start Gunicorn with Uvicorn workers
gunicorn app.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --timeout 120 \
  --access-logfile - \
  --error-logfile -
