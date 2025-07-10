FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy proto files
COPY ../proto/ ./proto/

# Generate Python proto files
RUN python -m grpc_tools.protoc -I./proto --python_out=. --grpc_python_out=. proto/*.proto

# Copy application code
COPY . .

# Expose port (optional, this service acts as a client)
EXPOSE 50053

# Run the application
CMD ["python", "main.py"]
