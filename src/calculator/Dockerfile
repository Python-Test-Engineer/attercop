# Simple Dockerfile for the calculator application
# We're using Python 3.11 slim for a lightweight but functional base
FROM python:3.12-alpine


# Set our working directory inside the container
WORKDIR /app

# Copy everything from our project into the container
# Since your calculator is self-contained, we don't need complex dependency management
COPY . .



# Set the Python path so Python can find our calculator module
# This is much simpler than complex path manipulation
ENV PYTHONPATH=/app/src

# For the main calculator, we don't need pytest at all
# We'll handle test dependencies separately in docker-compose
CMD ["python", "src/calculator/calculator.py"]
