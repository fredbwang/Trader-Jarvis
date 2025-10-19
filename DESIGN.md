# Trader Jarvis - Trading Toolset Design

## Project Overview
A simple trading platform with remote backend execution and local frontend display. Supports multiple brokerage connections, data visualization, and custom trading algorithms with both mock and live trading modes.

## Core Features
1. **Brokerage Integration** - Connect to multiple brokerage accounts and fetch data
2. **Data Visualization** - Chart data from multiple sources in unified interface
3. **Trading Algorithms** - Custom algorithms with mock/live trading modes
4. **Remote Execution** - Backend runs on remote server, frontend displays locally

## Tech Stack

### Backend (Remote Server)
- **Language**: Python 3.11+
- **API Framework**: FastAPI (async, WebSocket support)
- **Database**: TimescaleDB (PostgreSQL extension for time-series)
- **Cache**: Redis (real-time data caching)
- **Data Processing**: pandas, numpy, TA-Lib
- **Brokerage APIs**:
  - Alpaca API (stocks/crypto)
  - CCXT (multi-exchange crypto)
  - Interactive Brokers TWS API (stocks/options/futures)

### Frontend (Local)
- **Framework**: React + Next.js
- **Charting**: TradingView Lightweight Charts or Plotly
- **State Management**: Zustand or Redux
- **Communication**: WebSocket + REST API
- **UI Components**: shadcn/ui or Material-UI

## Key Components

### 1. Brokerage Connectors
- **Purpose**: Unified interface to different brokerages
- **Pattern**: Adapter pattern with common interface
- **Responsibilities**:
  - Authentication & connection management
  - Fetch real-time and historical data
  - Execute trades (buy/sell/cancel)

### 2. Data Aggregator
- **Purpose**: Normalize and merge data from multiple sources

### 3. Trading Engine
- **Purpose**: Execute trading algorithms
- **Modes**:
  - **Mock Mode**: Simulate trades with historical/paper account, and can do back testing.
  - **Live Mode**: Execute real trades via brokerages

### 4. Data Storage
- **TimescaleDB**: Historical price data, trades, performance metrics
- **Redis**: Real-time quotes, active orders, session data

