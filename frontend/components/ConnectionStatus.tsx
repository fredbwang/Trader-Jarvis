'use client'

import { useEffect, useState, useRef } from 'react'

const WS_URL = process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8000/ws'

type ConnectionState = 'connecting' | 'connected' | 'disconnected'

interface WebSocketMessage {
  type: string
  [key: string]: any
}

export default function ConnectionStatus() {
  const [status, setStatus] = useState<ConnectionState>('disconnected')
  const [lastMessage, setLastMessage] = useState<WebSocketMessage | null>(null)
  const [messageCount, setMessageCount] = useState(0)
  const wsRef = useRef<WebSocket | null>(null)

  const connect = () => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      return
    }

    setStatus('connecting')

    try {
      const ws = new WebSocket(WS_URL)

      ws.onopen = () => {
        console.log('WebSocket connected')
        setStatus('connected')
      }

      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data)
          setLastMessage(data)
          setMessageCount(prev => prev + 1)
          console.log('WebSocket message:', data)
        } catch (err) {
          console.error('Failed to parse WebSocket message:', err)
        }
      }

      ws.onerror = (error) => {
        console.error('WebSocket error:', error)
        setStatus('disconnected')
      }

      ws.onclose = () => {
        console.log('WebSocket disconnected')
        setStatus('disconnected')
        wsRef.current = null
      }

      wsRef.current = ws
    } catch (err) {
      console.error('Failed to create WebSocket:', err)
      setStatus('disconnected')
    }
  }

  const disconnect = () => {
    if (wsRef.current) {
      wsRef.current.close()
      wsRef.current = null
      setStatus('disconnected')
    }
  }

  const sendTestMessage = () => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      const message = {
        type: 'test',
        timestamp: new Date().toISOString(),
        data: 'Hello from frontend'
      }
      wsRef.current.send(JSON.stringify(message))
    }
  }

  useEffect(() => {
    connect()

    return () => {
      disconnect()
    }
  }, [])

  const getStatusClass = () => {
    switch (status) {
      case 'connected':
        return 'status-connected'
      case 'connecting':
        return 'status-connecting'
      case 'disconnected':
        return 'status-disconnected'
    }
  }

  const getStatusText = () => {
    switch (status) {
      case 'connected':
        return 'Connected'
      case 'connecting':
        return 'Connecting...'
      case 'disconnected':
        return 'Disconnected'
    }
  }

  return (
    <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-semibold">WebSocket</h2>
        <div className="flex gap-2">
          {status === 'disconnected' ? (
            <button
              onClick={connect}
              className="text-sm px-3 py-1 bg-green-600 hover:bg-green-700 rounded transition-colors"
            >
              Connect
            </button>
          ) : (
            <button
              onClick={disconnect}
              className="text-sm px-3 py-1 bg-red-600 hover:bg-red-700 rounded transition-colors"
            >
              Disconnect
            </button>
          )}
        </div>
      </div>

      <div className="space-y-3">
        <div className="flex items-center">
          <span className={`status-indicator ${getStatusClass()}`}></span>
          <span className="font-medium">{getStatusText()}</span>
        </div>

        <div className="text-sm text-gray-400">
          <span className="font-medium">Messages Received:</span> {messageCount}
        </div>

        {status === 'connected' && (
          <button
            onClick={sendTestMessage}
            className="text-sm px-3 py-1 bg-slate-700 hover:bg-slate-600 rounded transition-colors w-full"
          >
            Send Test Message
          </button>
        )}

        {lastMessage && (
          <div className="mt-4">
            <div className="text-sm font-medium text-gray-400 mb-2">Last Message:</div>
            <div className="bg-slate-900 p-3 rounded text-xs font-mono overflow-auto max-h-32">
              <pre>{JSON.stringify(lastMessage, null, 2)}</pre>
            </div>
          </div>
        )}

        <div className="text-xs text-gray-500 mt-2">
          Endpoint: {WS_URL}
        </div>
      </div>
    </div>
  )
}
