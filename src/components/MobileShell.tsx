import type { ReactNode } from 'react'

interface Props {
  children: ReactNode
}

export default function MobileShell({ children }: Props) {
  return (
    <div className="min-h-screen bg-[#c7d2fe] flex items-center justify-center p-6">
      <div
        className="relative flex flex-col overflow-hidden shadow-2xl"
        style={{
          width: 390,
          height: 844,
          borderRadius: 40,
          background: '#f8fafc',
          border: '8px solid #0F172A',
          boxShadow: '0 40px 80px rgba(0,0,0,0.35), inset 0 0 0 1px rgba(255,255,255,0.08)',
        }}
      >
        {/* Dynamic island */}
        <div className="absolute top-3 left-1/2 -translate-x-1/2 z-50">
          <div className="w-28 h-7 bg-[#0F172A] rounded-full" />
        </div>
        {/* Screen content */}
        <div className="flex-1 overflow-y-auto no-scrollbar">{children}</div>
      </div>
    </div>
  )
}
