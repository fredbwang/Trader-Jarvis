# Trader Jarvis - Frontend

Next.js frontend for the Trader Jarvis trading platform.

## Features

- Modern React with Next.js 14 (App Router)
- TypeScript for type safety
- Tailwind CSS for styling
- Real-time WebSocket connection to backend
- TradingView Lightweight Charts integration
- Zustand for state management

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.local.example .env.local
   ```
   Edit `.env.local` if needed (defaults to localhost:8000).

3. **Run the development server:**
   ```bash
   npm run dev
   ```

4. **Open your browser:**
   Navigate to [http://localhost:3000](http://localhost:3000)

## Project Structure

```
frontend/
├── app/                  # Next.js app directory
│   ├── globals.css      # Global styles
│   ├── layout.tsx       # Root layout
│   └── page.tsx         # Home page
├── components/          # React components
│   ├── ApiStatus.tsx    # Backend API status
│   └── ConnectionStatus.tsx  # WebSocket connection
├── public/              # Static assets
└── package.json         # Dependencies
```

## Development

The frontend runs on port 3000 by default and connects to the backend at http://localhost:8000.

Make sure the backend server is running before starting the frontend.

## Building for Production

```bash
npm run build
npm start
```
