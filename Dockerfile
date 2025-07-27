# syntax=docker/dockerfile:1

# Build stage
FROM python:3.12-slim as builder

# Install uv
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add uv to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY README.md ./
COPY uv.lock ./

# Copy source code
COPY src/ ./src/

# Install dependencies
RUN uv sync --frozen

# Test stage
FROM builder as test

# Copy test files
COPY tests/ ./tests/

# Run tests
RUN uv run pytest tests/ -v

# Development stage for generating lock files
FROM builder as dev

# This stage can be used to update uv.lock
CMD ["uv", "lock"]

# Production stage
FROM python:3.12-slim as production

# Install uv for production
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add uv to PATH
ENV PATH="/root/.local/bin:$PATH"

# Create non-root user
RUN useradd -m -u 1000 appuser

# Set working directory
WORKDIR /app

# Copy lock file and project files from builder
COPY --from=builder /app/uv.lock ./
COPY --from=builder /app/pyproject.toml ./
COPY --from=builder /app/README.md ./

# Install only production dependencies
RUN uv sync --frozen --no-dev

# Copy source code
COPY --from=builder /app/src/ ./src/

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set Python path
ENV PYTHONPATH=/app

# Run the application
CMD ["uv", "run", "python", "-m", "src.main"]