# Use an official Python runtime as a parent image
FROM python:3.12.4-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python3-dev

RUN python --version

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Create a virtual environment and install required packages
RUN pip install -U pip
RUN pip install -r requirements.txt

# Run the application
CMD ["./run.sh", "voice"]