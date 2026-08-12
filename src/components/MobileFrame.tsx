import { type ReactNode } from 'react'

export default function MobileFrame({ children }: { children: ReactNode }) {
  return (
    <div
      className="relative flex flex-col overflow-hidden"
      style={{
        width: 390,
        height: 844,
        borderRadius: 52,
        border: '10px solid #0F172A',
        boxShadow: '0 50px 100px rgba(15,23,42,0.45), 0 0 0 1px rgba(255,255,255,0.08) inset',
        background: '#F8FAFC',
      }}
    >
      {/* Status bar */}
      <div
        className="flex-shrink-0 flex items-center justify-between px-7"
        style={{ height: 44, background: '#0F172A' }}
      >
        <span className="text-white font-bold" style={{ fontSize: 12 }}>9:41</span>
        <div
          className="absolute"
          style={{
            left: '50%',
            transform: 'translateX(-50%)',
            top: 0,
            width: 110,
            height: 28,
            background: '#0F172A',
            borderRadius: '0 0 18px 18px',
          }}
        />
        <div className="flex items-center gap-1.5">
          {/* Signal bars */}
          <svg width="17" height="12" viewBox="0 0 17 12" fill="white">
            <rect x="0" y="7" width="3" height="5" rx="1" />
            <rect x="4.5" y="4.5" width="3" height="7.5" rx="1" />
            <rect x="9" y="2" width="3" height="10" rx="1" />
            <rect x="13.5" y="0" width="3" height="12" rx="1" opacity="0.3" />
          </svg>
          {/* Battery */}
          <svg width="26" height="13" viewBox="0 0 26 13" fill="none">
            <rect x="0.5" y="0.5" width="22" height="12" rx="3.5" stroke="white" strokeOpacity="0.5" />
            <rect x="2" y="2" width="19" height="9" rx="2" fill="white" />
            <path d="M24 4.5V8.5C24.9 8 25.5 7.3 25.5 6.5C25.5 5.7 24.9 5 24 4.5Z" fill="white" fillOpacity="0.5" />
          </svg>
        </div>
      </div>

      {/* Screen content */}
      <div className="flex-1 min-h-0 overflow-y-auto overflow-x-hidden flex flex-col" style={{ background: '#F8FAFC' }}>
        {children}
      </div>
    </div>
  )
}
