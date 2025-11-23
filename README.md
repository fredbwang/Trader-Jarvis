# Trader Jarvis

A comprehensive trading platform with remote backend execution and local frontend display. Supports multiple brokerage connections, data visualization, and custom trading algorithms with both mock and live trading modes.

## Project Structure

```
trader-jarvis/
├── backend/          # Python FastAPI backend
│   ├── main.py      # Main application entry point
│   ├── config.py    # Configuration management
│   └── requirements.txt
├── frontend/         # Next.js React frontend
│   ├── app/         # Next.js app directory
│   ├── components/  # React components
│   └── package.json
├── DESIGN.md        # Detailed technical design
└── RAMP-UP.md       # AI context and development guide
```

## Tech Stack

### Backend
- **Framework**: FastAPI (Python 3.11+)
- **Database**: TimescaleDB (PostgreSQL)
- **Cache**: Redis
- **Data Processing**: pandas, numpy, pandas-ta
- **Trading**: Backtrader, Alpaca API
- **Real-time**: WebSocket, Redis Streams

### Frontend
- **Framework**: Next.js 14 (React 18)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Charting**: TradingView Lightweight Charts
- **State**: Zustand

## Quick Start

### Easy Start (Windows)
Simply run the PowerShell script to start both servers:
```powershell
.\start.ps1
```
This will open two new PowerShell windows - one for the backend and one for the frontend.

To stop both servers:
```powershell
.\stop.ps1
```
This will gracefully terminate all backend and frontend processes.

### Prerequisites
- Python 3.11+
- Node.js 18+
- npm or yarn

### Manual Setup

#### 1. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run the server
python main.py
```

The backend will start on http://localhost:8000

#### 2. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Configure environment
cp .env.local.example .env.local
# Edit .env.local if needed

# Run the development server
npm run dev
```

The frontend will start on http://localhost:3000

## Features

### Current Implementation (Phase 1)
- ✅ FastAPI backend with WebSocket support
- ✅ Next.js frontend with real-time connection status
- ✅ API health monitoring
- ✅ WebSocket connection management
- ✅ Dark theme UI with Tailwind CSS

### Planned Features
- 🔄 Alpaca API integration
- 🔄 TimescaleDB integration
- 🔄 Redis Streams for real-time data
- 🔄 TradingView charts integration
- 🔄 Backtesting engine with Backtrader
- 🔄 Custom trading strategies
- 🔄 Real-time price streaming
- 🔄 Paper trading mode
- 🔄 Live trading mode (requires confirmation)

## Development Workflow

1. **Backend Development**: Make changes in `backend/`, the server auto-reloads
2. **Frontend Development**: Make changes in `frontend/`, Next.js auto-reloads
3. **API Documentation**: Visit http://localhost:8000/docs for interactive API docs

## API Endpoints

- `GET /` - API information
- `GET /health` - Health check
- `GET /docs` - Interactive API documentation (Swagger UI)
- `WS /ws` - WebSocket endpoint for real-time data

## Environment Variables

### Backend (.env)
- `HOST` - Server host (default: 127.0.0.1)
- `PORT` - Server port (default: 8000)
- `ALPACA_API_KEY` - Alpaca API key
- `ALPACA_SECRET_KEY` - Alpaca secret key
- `POSTGRES_*` - Database configuration
- `REDIS_*` - Redis configuration

### Frontend (.env.local)
- `NEXT_PUBLIC_API_URL` - Backend API URL (default: http://localhost:8000)
- `NEXT_PUBLIC_WS_URL` - WebSocket URL (default: ws://localhost:8000/ws)

## Documentation

- [Design Document](DESIGN.md) - Comprehensive technical design and architecture
- [Ramp-up Guide](RAMP-UP.md) - AI context and development guidelines
- [Backend README](backend/README.md) - Backend-specific documentation
- [Frontend README](frontend/README.md) - Frontend-specific documentation

## License

See [LICENSE](LICENSE) file for details.

## Contributing

This is a personal project for learning and experimentation. Feel free to fork and modify for your own use.

## Disclaimer

This software is for educational purposes only. Do not use with real money without proper testing and risk management. Trading involves risk and can result in financial loss.
