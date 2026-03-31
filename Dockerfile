### Stage 1: Build - install Python deps using `uv`
FROM python:3.14-slim AS django-builder
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app

# System deps for building some Python packages (keep minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a venv where dependencies will be installed
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install `uv` using pip cache mount
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip setuptools wheel uv

# Copy pyproject so uv can read dependencies (and the app code)
COPY pyproject.toml ./pyproject.toml
COPY src/ /app/

# Install production dependencies using `uv` (use pip cache mount)
RUN --mount=type=cache,target=/root/.cache/pip \
    uv sync

ENV PATH="/app/.venv/bin:$PATH"
RUN python manage.py collectstatic --noinput

### Stage 2: Runtime image
FROM python:3.14-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app

ENV PATH="/app/.venv/bin:$PATH"

# Copy application code
COPY --from=django-builder /app /app

# Create a non-root user for running the app
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

# Expose the port the app listens on
EXPOSE 8000

# Use granian
CMD ["granian", "--interface", "asgi", "--host", "0.0.0.0", "--port", "8000", "--loop", "uvloop", "web_jarvis.asgi:application", "--static-path-mount", "assets"]