"""Main FastAPI application entry point."""
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import uvicorn
from datetime import datetime
import json

from config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan context manager for startup and shutdown."""
    # Startup
    print(f"Starting Trader Jarvis API on {settings.host}:{settings.port}")
    print(f"Environment: {settings.env}")
    print(f"CORS Origins: {settings.cors_origins_list}")

    yield

    # Shutdown
    print("Shutting down Trader Jarvis API")


# Create FastAPI application
app = FastAPI(
    title="Trader Jarvis API",
    description="Trading platform backend with real-time data streaming and backtesting",
    version="0.1.0",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "0.1.0"
    }


# API info endpoint
@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "name": "Trader Jarvis API",
        "version": "0.1.0",
        "description": "Trading platform backend",
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "websocket": "/ws"
        }
    }


# WebSocket connection manager
class ConnectionManager:
    """Manages WebSocket connections."""

    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        """Accept and store a new WebSocket connection."""
        await websocket.accept()
        self.active_connections.append(websocket)
        print(f"Client connected. Total connections: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        """Remove a WebSocket connection."""
        self.active_connections.remove(websocket)
        print(f"Client disconnected. Total connections: {len(self.active_connections)}")

    async def broadcast(self, message: dict):
        """Send a message to all connected clients."""
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception as e:
                print(f"Error broadcasting to client: {e}")


manager = ConnectionManager()


# WebSocket endpoint
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time data streaming."""
    await manager.connect(websocket)

    try:
        # Send welcome message
        await websocket.send_json({
            "type": "connection",
            "status": "connected",
            "message": "Connected to Trader Jarvis API",
            "timestamp": datetime.utcnow().isoformat()
        })

        # Keep connection alive and handle incoming messages
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)

            # Echo back for now (will be replaced with actual logic)
            await websocket.send_json({
                "type": "echo",
                "data": message,
                "timestamp": datetime.utcnow().isoformat()
            })

    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(websocket)


if __name__ == "__main__":
    uvicorn.run(
        "trader-jarvis-backend:app",
        host=settings.host,
        port=settings.port,
        reload=settings.env == "development"
    )
