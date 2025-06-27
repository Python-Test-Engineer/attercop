# Use Python 3.12 slim image for efficiency
FROM python:3.12-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast dependency management
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency files first for better caching
COPY pyproject.toml requirements.txt uv.lock ./
COPY uv.config.json ./

# Install dependencies using uv
RUN uv sync

# Copy source code
COPY src/ ./src/
COPY main.py ./

# Add src to Python path so imports work correctly
ENV PYTHONPATH=/app/src

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

# Default command runs the tests
CMD ["python", "-m", "pytest", "src/tests/", "-v"]
