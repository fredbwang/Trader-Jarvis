# Trader Jarvis - Quick Ramp-Up Guide

## Project Summary
Trading platform with remote backend + local frontend. Supports brokerage connections, data visualization, custom algorithms, and backtesting.

## Tech Stack

**Backend:**
- Python 3.11+ / FastAPI / WebSocket
- TimescaleDB (time-series data)
- Redis (caching + streams)
- Backtrader (backtesting)
- pandas-ta (indicators: MA, RSI, MACD)

**Frontend:**
- React + Next.js
- TradingView Lightweight Charts (supports buy/sell trade markers)
- WebSocket for real-time data
- UI Components: TBD (shadcn/ui or Ant Design)

**Brokerages:**
- Phase 1: Alpaca (US stocks, paper trading, free API)
- Phase 2: Interactive Brokers (advanced, personal account access)

## Architecture

```
Alpaca WebSocket → Redis Stream → [Trading Engine | Storage Worker | Frontend]
                                           ↓
                                     TimescaleDB
```

## Key Decisions

### 1. Brokerage Integration
- **Alpaca** (`alpaca-py`) for Phase 1
- US stocks only
- Free paper trading + 5 years historical data
- Tick-by-tick real-time streaming

### 2. Data Aggregator
- **Real-time**: Alpaca WebSocket → Redis Streams (message persistence)
- **Historical**: Alpaca API → TimescaleDB cache
- **Pre-cached**: TSLA, NVDA, SPY (5 years of 1-min bars)
- **Data flow**: Single source (Alpaca), execute on multiple accounts (Alpaca/IBKR)

### 3. Trading Engine
- **Framework**: Backtrader (easy, well-documented)
- **Indicators**: pandas-ta (MA, RSI, MACD)
- **Phase 1**: Mock mode/backtesting only, no risk controls
- **Phase 2**: Paper trading (Alpaca paper account)
- **Phase 3**: Live trading (with safety checks)

### 4. Data Storage
- **TimescaleDB**: 1-second bars, trades, performance (~3.5 GB/year for 3 symbols)
- **Redis**: Real-time tick data (24h retention), Redis Streams, cache
- **ORM**: SQLAlchemy 2.0 + asyncpg
- **Deployment**: Docker (timescaledb-ha:pg16 + redis:7-alpine)
- **Storage**: 1-sec resolution bars, compression after 7 days
- **Pre-cache**: 5 years of data for TSLA, NVDA, SPY

## Phase 1 Scope
- Alpaca integration (data + paper trading)
- Redis Streams for real-time tick data
- TimescaleDB with pre-cached symbols (TSLA, NVDA, SPY)
- Backtrader backtesting engine
- Strategy plugin system (user extends BaseStrategy)
- No risk management yet

## What's NOT in Phase 1
- IBKR integration (Phase 2)
- Live trading (Phase 3)
- Risk controls (stop-loss, position sizing - Phase 3)
- Frontend (TBD)

