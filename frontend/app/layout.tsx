import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Trader Jarvis',
  description: 'Trading platform with real-time data and backtesting',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
