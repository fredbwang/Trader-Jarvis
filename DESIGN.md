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
  - **Phase 1**: Alpaca API (`alpaca-py`) - US stocks, free historical data, paper trading
  - **Phase 2**: Interactive Brokers API (`ib_insync`) - Professional trading, personal account access

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
- **Real-time Data Strategy**:
  - Single source: Alpaca WebSocket (tick-by-tick data)
  - Redis Streams for message distribution
  - Multiple consumers: Trading Engine, Storage Worker, Frontend
- **Historical Data Strategy**:
  - Primary source: Alpaca API (5 years, 15-min delayed, free)
  - Local caching: TimescaleDB for frequently used symbols
  - Pre-cached symbols: TSLA, NVDA, SPY (5 years of 1-min bars)
- **Libraries**:
  - `pandas` - DataFrame operations, resampling
  - `numpy` - Numerical computations
  - `pydantic` - Data validation and schemas
  - `redis-py` or `aioredis` - Redis Streams client

### 3. Trading Engine
- **Purpose**: Execute trading algorithms
- **Modes**:
  - **Mock Mode**: Simulate trades with historical/paper account, and can do back testing.
  - **Live Mode**: Execute real trades via brokerages

### 4. Data Storage
- **TimescaleDB**: Historical price data, trades, performance metrics
- **Redis**: Real-time quotes, active orders, session data

---

## Component Details

### Brokerage Integration

**Phase 1: Alpaca (US Stocks Only)**

**Library:** `alpaca-py==0.21.0`

**Features:**
- Free paper trading account
- 5 years historical data (15-min delayed for consolidated, real-time for IEX)
- Tick-by-tick real-time streaming via WebSocket
- Commission-free trading
- SIPC insured ($500k + excess coverage up to $30M)
- Self-clearing broker-dealer

**API Capabilities:**
- Account info, positions, orders
- Historical bars (1min to 1day), quotes, trades
- Real-time market data streaming (trades, quotes, bars)
- Place/cancel orders (market, limit, stop, stop-limit, etc.)

**Limitations:**
- US stocks only (no options/futures in Phase 1)
- Real-time consolidated feed requires paid subscription

---

**Phase 2: Interactive Brokers (Advanced Trading)**

**Library:** `ib_insync==0.9.86`

**Features:**
- FREE API access for personal accounts
- Access to existing IB account + trading history
- Paper trading account available
- Stocks, options, futures, forex, bonds
- Global markets

**Additional Costs:**
- Market data subscriptions ($1-10/month per exchange)
- Trading commissions (~$0.005/share, min $1)

**Use Case:**
- Execute trades on personal IB account
- Advanced products (options strategies)
- Multiple accounts management (Alpaca for data, IB for execution)

---

### Data Aggregator Architecture

**Real-time Data Flow:**
```
Alpaca WebSocket (tick data: trades, quotes)
         ↓
Backend Data Ingestion Service
         ↓
Redis Stream ("market_data" stream)
         ↓
    ┌────┴──────┬──────────────┐
    ↓           ↓              ↓
Trading     Storage      WebSocket
Engine      Worker       Server
(Execute)   (Persist)    (Frontend)
```

**Historical Data Flow:**
```
Client Request (symbol, start, end, timeframe)
         ↓
Check TimescaleDB Cache
         ↓
    ┌────┴────┐
    ↓         ↓
  Found    Not Found
    ↓         ↓
  Return   Fetch from Alpaca API
            ↓
       Cache to TimescaleDB
            ↓
          Return
```

**Data Caching Strategy:**

**Pre-cached Symbols:** TSLA, NVDA, SPY
- **Data Range**: 5 years of 1-minute bars (~1.8M rows per symbol)
- **Storage**: TimescaleDB with compression
- **Update**: Daily job to fetch latest bars

**On-demand Symbols:**
- Fetched from Alpaca API as needed
- Cached to TimescaleDB after first fetch
- LRU eviction for storage management (optional)

**Redis Streams vs Pub/Sub Decision:**
- **Chosen**: Redis Streams
- **Reasons**:
  - Message persistence (can replay if consumer crashes)
  - Consumer groups (load balancing)
  - Delivery acknowledgments (at-least-once guarantee)
  - Message history for debugging
  - Minimal overhead for 3 concurrent symbols

---

### Trading Engine Architecture

**Framework:** Backtrader (`backtrader==1.9.78.123`)

**Why Backtrader:**
- Well-documented, mature framework
- Built-in broker simulation (realistic fills, slippage)
- Performance analyzers (returns, Sharpe ratio, drawdown)
- Perfect for 3 symbols with moderate data volume
- Easy integration with custom data feeds

**Technical Indicators:** pandas-ta (`pandas-ta==0.3.14b`)

**Why pandas-ta:**
- Pure Python (easy Windows installation)
- Works with pandas DataFrames
- Includes required indicators:
  - Moving Averages (SMA, EMA, WMA)
  - RSI (Relative Strength Index)
  - MACD (MACD line, signal line, histogram)

**Trading Modes:**

**Phase 1 - Mock Mode (Backtesting):**
- Load historical data from TimescaleDB
- Backtrader simulates order execution
- Calculate performance metrics
- Store results to database
- **No risk controls** (deferred to later phases)

**Phase 2 - Paper Trading:**
- Real-time data from Redis Stream
- Execute on Alpaca paper account
- Test strategies in live market conditions

**Phase 3 - Live Trading:**
- Explicit user confirmation required
- Execute on Alpaca/IBKR live accounts
- Add risk controls (stop-loss, position sizing, max drawdown)

**Strategy Plugin System:**

Users implement custom strategies by extending base class:

```python
class BaseStrategy(bt.Strategy):
    def __init__(self):
        # Initialize indicators
        pass

    def next(self):
        # Trading logic for each bar
        pass
```

**Example Strategy:**
```python
class MAStrategy(BaseStrategy):
    def __init__(self):
        self.sma_fast = bt.indicators.SMA(period=10)
        self.sma_slow = bt.indicators.SMA(period=30)

    def next(self):
        if self.sma_fast > self.sma_slow:
            self.buy()
        elif self.sma_fast < self.sma_slow:
            self.sell()
```

**Phase 1 Scope:**
- Backtesting only (mock mode)
- No risk management
- Focus on strategy development and testing

---

### Database & Caching Architecture

**TimescaleDB Setup:**

**Deployment:** Docker (`timescale/timescaledb-ha:pg16`)

**Data Storage Strategy:**

**1-Second Bars (Primary Storage):**
- **Resolution**: 1-second OHLCV bars
- **Volume**: ~70K rows/day for 3 symbols (TSLA, NVDA, SPY)
- **Storage**: ~10 MB/day, ~3.5 GB/year
- **Retention**: Unlimited (with compression)
- **Compression**: Enabled after 7 days (reduces to ~10-20% of original size)

**Tick Data:**
- **Not stored** in TimescaleDB (too large)
- Kept in Redis Streams with 24h retention
- Real-time only, not for historical backtesting

**Schema:**
```sql
-- OHLCV bars (1-second resolution)
CREATE TABLE ohlcv (
    time TIMESTAMPTZ NOT NULL,
    symbol TEXT NOT NULL,
    open DOUBLE PRECISION,
    high DOUBLE PRECISION,
    low DOUBLE PRECISION,
    close DOUBLE PRECISION,
    volume BIGINT,
    timeframe TEXT,  -- '1s', '1m', '5m', '1h', '1d'
    source TEXT      -- 'alpaca', 'ibkr'
);
SELECT create_hypertable('ohlcv', 'time');
CREATE INDEX idx_ohlcv_symbol_time ON ohlcv (symbol, time DESC);

-- Trades
CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    time TIMESTAMPTZ NOT NULL,
    symbol TEXT NOT NULL,
    side TEXT,  -- 'buy', 'sell'
    quantity DOUBLE PRECISION,
    price DOUBLE PRECISION,
    strategy TEXT,
    mode TEXT,  -- 'backtest', 'paper', 'live'
    account TEXT  -- 'alpaca', 'ibkr'
);

-- Backtest results
CREATE TABLE backtest_results (
    id SERIAL PRIMARY KEY,
    strategy TEXT,
    symbol TEXT,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    total_return DOUBLE PRECISION,
    sharpe_ratio DOUBLE PRECISION,
    max_drawdown DOUBLE PRECISION,
    total_trades INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**ORM & Database Access:**

**Library:** SQLAlchemy 2.0 + asyncpg

**Benefits:**
- Type-safe Python models
- Async support for FastAPI integration
- Alembic for database migrations
- Can mix with raw SQL for TimescaleDB-specific features

**Example:**
```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

engine = create_async_engine('postgresql+asyncpg://...')

async with AsyncSession(engine) as session:
    result = await session.execute(
        select(OHLCV)
        .where(OHLCV.symbol == "TSLA")
        .where(OHLCV.time > datetime(2025, 1, 1))
    )
    bars = result.scalars().all()
```

---

**Redis Configuration:**

**Deployment:** Docker (`redis:7-alpine`)

**Library:** `redis[hiredis]==5.0.1` (includes C parser for performance)

**Use Cases:**

**1. Redis Streams (Real-time Tick Data)**
```
Stream: market_data
Key format: market_data:{symbol}
Retention: 24 hours or 100,000 entries (whichever comes first)
Consumer groups: trading_engine, storage_worker, websocket_server
```

**2. Cache (Hot Data)**
```
Key: quote:{symbol}          TTL: 1 second
Key: bar:1s:{symbol}:{date}  TTL: 1 hour
Key: positions:{account}     TTL: 5 minutes
```

**3. Session Data**
```
Key: session:{user_id}       TTL: 7 days
```

**Data Flow:**

**Real-time:**
```
Alpaca WebSocket (ticks) → Backend → Redis Stream
                                           ↓
                          ┌────────────────┼────────────────┐
                          ↓                ↓                ↓
                   Trading Engine   Storage Worker   WebSocket Server
                   (consume)        (aggregate to     (forward to
                                    1s bars → DB)     frontend)
```

**Historical:**
```
Request 1-sec bars → TimescaleDB
Request 1-min bars → Aggregate from 1-sec bars (on-the-fly)
Request 5-min bars → Aggregate from 1-sec bars (on-the-fly)
```

**Pre-caching Strategy:**
- Load 5 years of 1-minute bars for TSLA, NVDA, SPY on startup
- Aggregate to 1-second bars as needed (or fetch from Alpaca if available)
- Daily job to update with latest data

---

### Frontend Architecture

**Charting Library:** TradingView Lightweight Charts

**Why TradingView:**
- Free, open-source
- Built specifically for trading (candlesticks, volume, technical indicators)
- **Supports trade markers** (buy/sell arrows on chart)
- Lightweight, fast real-time updates
- WebSocket integration for live data
- Professional trading UI

**Trade Marker Example:**
```typescript
series.setMarkers([
  {
    time: '2025-01-15 10:30:00',
    position: 'belowBar',
    color: 'green',
    shape: 'arrowUp',
    text: 'BUY @ $150.25'
  },
  {
    time: '2025-01-15 14:45:00',
    position: 'aboveBar',
    color: 'red',
    shape: 'arrowDown',
    text: 'SELL @ $155.80'
  }
]);
```

**UI Framework:** React + Next.js (confirmed)

**State Management:** TBD (options: Zustand, Redux Toolkit)

**UI Components:** TBD (options: shadcn/ui, Ant Design)

**WebSocket Client:** Native WebSocket API (start simple)

**Frontend Features (Phase 1):**
- Real-time price chart with candlesticks
- Buy/sell trade markers on chart
- Technical indicators overlay (MA, RSI, MACD)
- Backtest results visualization
- Basic strategy controls (start/stop)

