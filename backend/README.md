# Trader Jarvis - Backend

FastAPI backend for the Trader Jarvis trading platform.

## Features

- RESTful API with FastAPI
- WebSocket support for real-time data streaming
- CORS configured for frontend connection
- Environment-based configuration
- Health check endpoint

## Setup

1. **Create a virtual environment:**
   ```bash
   python -m venv venv
   ```

2. **Activate the virtual environment:**
   - Windows:
     ```bash
     venv\Scripts\activate
     ```
   - macOS/Linux:
     ```bash
     source venv/bin/activate
     ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your configuration.

5. **Run the server:**
   ```bash
   python trader-jarvis-backend.py
   ```
   Or with uvicorn:
   ```bash
   uvicorn trader-jarvis-backend:app --reload --host 127.0.0.1 --port 8000
   ```

## API Endpoints

- `GET /` - API information
- `GET /health` - Health check
- `GET /docs` - Interactive API documentation (Swagger UI)
- `GET /redoc` - Alternative API documentation (ReDoc)
- `WS /ws` - WebSocket endpoint for real-time data

## Development

The server runs in development mode by default with auto-reload enabled.

Access the API at: http://localhost:8000

Access the interactive docs at: http://localhost:8000/docs
