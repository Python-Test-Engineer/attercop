# Docker Setup for Calculator Application

This document provides instructions for building and running the calculator application in a Docker container, specifically for running tests.

## Prerequisites

- Docker installed on your system
- Basic familiarity with Docker commands

## Building the Docker Image

Build the Docker image from the project root directory:

```bash
docker build -t calculator-app .
```

This command:
- Uses the `Dockerfile` in the current directory
- Tags the image as `calculator-app`
- Installs all dependencies using `uv` for fast package management
- Sets up the proper Python environment

## Running Tests in the Container

### Run All Tests (Default)

The container is configured to run tests by default:

```bash
docker run --rm calculator-app
```

This will:
- Run all tests in the `src/tests/` directory
- Display verbose output (`-v` flag)
- Remove the container after execution (`--rm` flag)

### Run Tests with Custom Options

You can pass additional pytest options:

```bash
# Run tests with even more verbose output
docker run --rm calculator-app python -m pytest src/tests/ -vv

# Run a specific test file
docker run --rm calculator-app python -m pytest src/tests/test_calculator.py -v

# Run tests with coverage reporting (if coverage is installed)
docker run --rm calculator-app python -m pytest src/tests/ --cov=calculator --cov-report=term-missing
```

### Interactive Development

For development and debugging, you can run the container interactively:

```bash
# Start an interactive bash session
docker run --rm -it calculator-app bash

# Once inside the container, you can run tests manually:
python -m pytest src/tests/ -v

# Or run individual test methods:
python -m pytest src/tests/test_calculator.py::TestCalculator::test_add -v
```

### Mount Local Code for Development

To work with your local code changes without rebuilding the image:

```bash
# Mount the src directory as a volume (Linux/Mac)
docker run --rm -v "$(pwd)/src:/app/src" calculator-app

# For Windows PowerShell:
docker run --rm -v "${PWD}/src:/app/src" calculator-app

# For Windows Command Prompt:
docker run --rm -v "%cd%/src:/app/src" calculator-app
```

## Container Features

### Security
- Runs as a non-root user (`app`) for security
- Minimal base image (Python 3.12 slim)

### Performance
- Uses `uv` for fast dependency installation
- Optimized layer caching for faster rebuilds
- Excludes unnecessary files via `.dockerignore`

### Python Environment
- Python 3.12 runtime
- All project dependencies installed
- Proper PYTHONPATH configuration for imports (`/app/src`)

## Troubleshooting

### Import Errors
If you encounter import errors, ensure the PYTHONPATH is correctly set. The Dockerfile sets:
```
ENV PYTHONPATH=/app/src
```

### Permission Issues
The container runs as a non-root user. If you encounter permission issues when mounting volumes, you may need to adjust file permissions on your host system.

### Dependency Issues
If you modify `requirements.txt` or `pyproject.toml`, rebuild the Docker image:
```bash
docker build -t calculator-app . --no-cache
```

### UV Installation Issues
If you encounter issues with `uv pip install`, ensure your `requirements.txt` is properly formatted and all dependencies are available.

## Advanced Usage

### Running Other Commands

You can override the default command to run other operations:

```bash
# Run the main application
docker run --rm calculator-app python main.py

# Run linting (if ruff is available)
docker run --rm calculator-app python -m ruff check src/

# Access Python REPL
docker run --rm -it calculator-app python
```

### Build Arguments

You can customize the build process with build arguments:

```bash
# Build with a different Python version (modify Dockerfile accordingly)
docker build -t calculator-app --build-arg PYTHON_VERSION=3.11 .
```

## Example Test Output

When running tests successfully, you should see output similar to:

```
========================= test session starts =========================
platform linux -- Python 3.12.x, pytest-8.x.x, pluggy-1.x.x
rootdir: /app
collected 5 items

src/tests/test_calculator.py::TestCalculator::test_add PASSED    [ 20%]
src/tests/test_calculator.py::TestCalculator::test_subtract PASSED [ 40%]
src/tests/test_calculator.py::TestCalculator::test_multiply PASSED [ 60%]
src/tests/test_calculator.py::TestCalculator::test_divide PASSED [ 80%]
src/tests/test_calculator.py::TestCalculator::test_divide_by_zero PASSED [100%]

========================= 5 passed in 0.xx seconds =========================
```

## Quick Start Commands

Here's a summary of the most common commands:

```bash
# Build the image
docker build -t calculator-app .

# Run tests
docker run --rm calculator-app

# Interactive development
docker run --rm -it calculator-app bash

# Run with local code mounted
docker run --rm -v "$(pwd)/src:/app/src" calculator-app
