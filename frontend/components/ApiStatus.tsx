'use client'

import { useEffect, useState } from 'react'
import axios from 'axios'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

interface ApiHealth {
  status: string
  timestamp: string
  version: string
}

export default function ApiStatus() {
  const [health, setHealth] = useState<ApiHealth | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const checkHealth = async () => {
    try {
      setLoading(true)
      setError(null)
      const response = await axios.get(`${API_URL}/health`, {
        timeout: 5000
      })
      setHealth(response.data)
    } catch (err) {
      setError('Failed to connect to backend')
      setHealth(null)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    checkHealth()
    const interval = setInterval(checkHealth, 10000) // Check every 10 seconds
    return () => clearInterval(interval)
  }, [])

  const getStatusClass = () => {
    if (loading) return 'status-connecting'
    if (error || !health) return 'status-disconnected'
    return 'status-connected'
  }

  const getStatusText = () => {
    if (loading) return 'Checking...'
    if (error || !health) return 'Disconnected'
    return 'Connected'
  }

  return (
    <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-semibold">Backend API</h2>
        <button
          onClick={checkHealth}
          className="text-sm px-3 py-1 bg-slate-700 hover:bg-slate-600 rounded transition-colors"
          disabled={loading}
        >
          Refresh
        </button>
      </div>

      <div className="space-y-3">
        <div className="flex items-center">
          <span className={`status-indicator ${getStatusClass()}`}></span>
          <span className="font-medium">{getStatusText()}</span>
        </div>

        {health && (
          <>
            <div className="text-sm text-gray-400">
              <span className="font-medium">Version:</span> {health.version}
            </div>
            <div className="text-sm text-gray-400">
              <span className="font-medium">Last Check:</span>{' '}
              {new Date(health.timestamp).toLocaleTimeString()}
            </div>
          </>
        )}

        {error && (
          <div className="text-sm text-red-400 bg-red-900/20 p-3 rounded border border-red-800">
            {error}
          </div>
        )}

        <div className="text-xs text-gray-500 mt-2">
          Endpoint: {API_URL}
        </div>
      </div>
    </div>
  )
}
