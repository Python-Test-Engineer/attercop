There are several effective approaches for testing Docker containers with different Python versions, each with distinct advantages:

## 1. Multi-stage Dockerfile with Build Args (Recommended)

Create a single Dockerfile that accepts the Python version as a build argument:

```dockerfile
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

Then build for different versions:
```bash
docker build --build-arg PYTHON_VERSION=3.9 -t myapp:py39 .
docker build --build-arg PYTHON_VERSION=3.10 -t myapp:py310 .
docker build --build-arg PYTHON_VERSION=3.11 -t myapp:py311 .
```

## 2. GitHub Actions Matrix Strategy

Use GitHub Actions to test multiple Python versions automatically:

```yaml
name: Test Docker Images
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11', '3.12']

    steps:
    - uses: actions/checkout@v3

    - name: Build Docker image
      run: |
        docker build --build-arg PYTHON_VERSION=${{ matrix.python-version }} \
          -t myapp:py${{ matrix.python-version }} .

    - name: Run tests
      run: |
        docker run --rm myapp:py${{ matrix.python-version }} python -m pytest
```

## 3. Docker Compose for Local Development

Create a `docker-compose.yml` for testing multiple versions locally:

```yaml
version: '3.8'
services:
  app-py39:
    build:
      context: .
      args:
        PYTHON_VERSION: 3.9
    volumes:
      - .:/app
    command: python -m pytest

  app-py310:
    build:
      context: .
      args:
        PYTHON_VERSION: 3.10
    volumes:
      - .:/app
    command: python -m pytest
```

## Best Practices

**For CI/CD**: Use GitHub Actions matrix strategy combined with parameterized Dockerfiles. This gives you automated testing across versions with minimal configuration duplication.

**For local development**: Use Docker Compose or build scripts that iterate through Python versions.

**For production**: Build separate images for each Python version you need to support, using clear tagging conventions.

The GitHub Actions matrix approach is generally preferred because it provides automatic testing, parallel execution, and integrates well with modern CI/CD workflows. The parameterized Dockerfile approach keeps your Docker configuration DRY while still allowing flexibility.
