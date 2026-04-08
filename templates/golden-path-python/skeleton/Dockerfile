FROM python:3.11-slim

WORKDIR /app

# Install runtime dependencies
RUN pip install --no-cache-dir fastapi uvicorn

# Copy application source
COPY app/ app/

EXPOSE 8080

# Start the service
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
