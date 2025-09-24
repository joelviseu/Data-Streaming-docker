# Data Streaming with Docker

## Project Overview
This project demonstrates how to implement data streaming using Docker. It provides a scalable and efficient way to process and analyze streaming data in real-time.

## Folder Structure
```
Data-Streaming-docker/
├── docker-compose.yml
├── README.md
├── src/
│   ├── producer/
│   └── consumer/
└── config/
```

## Quickstart Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/joelviseu/Data-Streaming-docker.git
   cd Data-Streaming-docker
   ```

2. Build and run the Docker containers:
   ```bash
   docker-compose up --build
   ```

3. Access the application via your web browser at `http://localhost:8080`.

## Architecture
The architecture consists of producers and consumers that communicate through a message broker. The Docker containers are orchestrated using Docker Compose, enabling easy management of the services.
