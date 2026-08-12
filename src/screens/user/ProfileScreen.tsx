import BottomNav from '../../components/BottomNav'
import SeverityBadge from '../../components/SeverityBadge'
import { mockReports, type Report } from '../../data/mockData'

interface Props {
  navigate: (screen: string) => void
  onViewReport: (r: Report) => void
}

const BADGES = [
  { id: 'top', label: 'Top Reporter', icon: '🏆', color: '#fef3c7', text: '#92400e' },
  { id: 'verified', label: 'Verified', icon: '✅', color: '#dcfce7', text: '#15803d' },
  { id: 'hero', label: 'Community Hero', icon: '🦸', color: '#ede9fe', text: '#6d28d9' },
]

export default function ProfileScreen({ navigate, onViewReport }: Props) {
  const myReports = mockReports.slice(0, 4)

  return (
    <div className="flex flex-col h-full">
      {/* App bar */}
      <div
        className="flex-shrink-0 flex items-center justify-between px-5"
        style={{ height: 56, background: '#0F172A' }}
      >
        <span className="text-white font-bold" style={{ fontSize: 16 }}>My Profile</span>
        <button>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
            <circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" strokeLinecap="round" />
          </svg>
        </button>
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Profile header */}
        <div
          className="flex flex-col items-center py-6 px-5"
          style={{ background: 'linear-gradient(180deg, #0F172A 0%, #1e3a5f 100%)' }}
        >
          <div
            className="rounded-full flex items-center justify-center text-white font-bold border-4 border-white shadow-xl"
            style={{ width: 72, height: 72, background: '#4361EE', fontSize: 26 }}
          >
            AF
          </div>
          <div className="text-white font-bold mt-3" style={{ fontSize: 18 }}>Ahmad Farid bin Zainal</div>
          <div style={{ color: '#94a3b8', fontSize: 13, marginTop: 2 }}>ahmad.farid@email.com</div>
          <div style={{ color: '#94a3b8', fontSize: 12, marginTop: 1 }}>+60 12-345 6789</div>

          {/* Stats */}
          <div className="flex gap-4 mt-4">
            {[
              { label: 'Points', value: '1,250', icon: '⭐' },
              { label: 'Reports', value: '23', icon: '📍' },
              { label: 'Verified', value: '87', icon: '✅' },
            ].map((s) => (
              <div
                key={s.label}
                className="flex flex-col items-center rounded-xl px-5 py-3"
                style={{ background: 'rgba(255,255,255,0.1)', minWidth: 72 }}
              >
                <span style={{ fontSize: 18 }}>{s.icon}</span>
                <div className="text-white font-bold" style={{ fontSize: 18, marginTop: 2 }}>{s.value}</div>
                <div style={{ color: '#94a3b8', fontSize: 10, fontWeight: 500 }}>{s.label}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="px-4 py-4 space-y-4">
          {/* Badges */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <div className="font-bold text-slate-800" style={{ fontSize: 14 }}>My Badges</div>
              <span style={{ color: '#4361EE', fontSize: 12, fontWeight: 600 }}>3 earned</span>
            </div>
            <div className="flex gap-2 flex-wrap">
              {BADGES.map((b) => (
                <div
                  key={b.id}
                  className="flex items-center gap-1.5 rounded-full"
                  style={{ padding: '6px 12px', background: b.color }}
                >
                  <span style={{ fontSize: 14 }}>{b.icon}</span>
                  <span style={{ fontSize: 12, fontWeight: 600, color: b.text }}>{b.label}</span>
                </div>
              ))}
              <div
                className="flex items-center gap-1.5 rounded-full"
                style={{ padding: '6px 12px', background: '#f1f5f9', border: '1.5px dashed #cbd5e1' }}
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" strokeWidth="2">
                  <path d="M12 5v14M5 12h14" strokeLinecap="round" />
                </svg>
                <span style={{ fontSize: 12, fontWeight: 600, color: '#94a3b8' }}>Earn more</span>
              </div>
            </div>
          </div>

          {/* Report history */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <div className="font-bold text-slate-800" style={{ fontSize: 14 }}>My Reports</div>
              <span style={{ color: '#4361EE', fontSize: 12, fontWeight: 600 }}>See all 23</span>
            </div>
            <div className="space-y-2">
              {myReports.map((r) => (
                <button
                  key={r.id}
                  onClick={() => onViewReport(r)}
                  className="w-full flex items-center gap-3 rounded-2xl p-3 text-left transition-transform active:scale-98"
                  style={{ background: '#fff', border: '1px solid #E2E8F0' }}
                >
                  <img
                    src={r.imageUrl}
                    alt={r.title}
                    className="flex-shrink-0 rounded-xl object-cover"
                    style={{ width: 52, height: 52 }}
                  />
                  <div className="flex-1 min-w-0">
                    <div className="font-semibold text-slate-800 truncate" style={{ fontSize: 13 }}>{r.title}</div>
                    <div style={{ fontSize: 11, color: '#94a3b8', marginTop: 1 }}>{r.location.split(',')[0]}</div>
                    <SeverityBadge severity={r.severity} />
                  </div>
                  <div className="text-right flex-shrink-0">
                    <div
                      style={{
                        fontSize: 10,
                        fontWeight: 700,
                        padding: '3px 8px',
                        borderRadius: 20,
                        background: r.status === 'resolved' ? '#dcfce7' : r.status === 'active' ? '#dbeafe' : '#fef3c7',
                        color: r.status === 'resolved' ? '#15803d' : r.status === 'active' ? '#1d4ed8' : '#92400e',
                        textTransform: 'capitalize',
                      }}
                    >
                      {r.status}
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </div>
        <div style={{ height: 8 }} />
      </div>

      <BottomNav active="profile" navigate={navigate} />
    </div>
  )
}
