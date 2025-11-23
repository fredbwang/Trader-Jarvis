'use client'

import { useEffect, useState } from 'react'
import ConnectionStatus from '@/components/ConnectionStatus'
import ApiStatus from '@/components/ApiStatus'

export default function Home() {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return null
  }

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-2">Trader Jarvis</h1>
          <p className="text-gray-400">Trading platform with real-time data and backtesting</p>
        </div>

        {/* Connection Status Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <ApiStatus />
          <ConnectionStatus />
        </div>

        {/* Welcome Section */}
        <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
          <h2 className="text-2xl font-semibold mb-4">Welcome to Trader Jarvis</h2>
          <div className="space-y-4 text-gray-300">
            <p>
              This is your trading platform dashboard. The system provides:
            </p>
            <ul className="list-disc list-inside space-y-2 ml-4">
              <li>Real-time market data streaming via WebSocket</li>
              <li>Multiple brokerage integration (Alpaca, Interactive Brokers)</li>
              <li>Custom trading algorithms with backtesting</li>
              <li>Advanced charting with TradingView Lightweight Charts</li>
              <li>Mock and live trading modes</li>
            </ul>
            <div className="mt-6 p-4 bg-slate-900 rounded border border-slate-600">
              <p className="text-sm text-gray-400">
                <strong>Note:</strong> Make sure the backend server is running on{' '}
                <code className="text-blue-400">http://localhost:8000</code>
              </p>
            </div>
          </div>
        </div>

        {/* Quick Stats Placeholder */}
        <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
            <h3 className="text-sm font-medium text-gray-400 mb-2">Active Strategies</h3>
            <p className="text-3xl font-bold">0</p>
          </div>
          <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
            <h3 className="text-sm font-medium text-gray-400 mb-2">Watched Symbols</h3>
            <p className="text-3xl font-bold">3</p>
            <p className="text-sm text-gray-500 mt-1">TSLA, NVDA, SPY</p>
          </div>
          <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
            <h3 className="text-sm font-medium text-gray-400 mb-2">Portfolio Value</h3>
            <p className="text-3xl font-bold">$0.00</p>
          </div>
        </div>
      </div>
    </main>
  )
}
