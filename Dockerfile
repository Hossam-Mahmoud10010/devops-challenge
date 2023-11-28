# Use a minimal base image
FROM python:3.9-slim

# Creating a non-root user Shaw and Partners
RUN useradd -ms /bin/bash sp

# Getting curl for healthcheck
RUN apt update && apt install -y curl

# Set the working directory
WORKDIR /app

# Installing dependencies
COPY src/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copying only necessary files
COPY src/application.py src/wsgi.py /app/

# Switch to the non-root user
RUN chown -R sp:sp /app
USER sp

# Exposing application port
EXPOSE 8888

# Healthcheck
HEALTHCHECK CMD curl --fail http://localhost:8888/healthcheck || exit 1

# Running the application
CMD ["gunicorn", "--bind", "0.0.0.0:8888", "wsgi:app"]