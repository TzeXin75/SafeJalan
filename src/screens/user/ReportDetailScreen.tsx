import { useState } from 'react'
import SeverityBadge from '../../components/SeverityBadge'
import { type Report, mockReports } from '../../data/mockData'

interface Props {
  navigate: (screen: string) => void
  report: Report | null
}

const TIMELINE = [
  { time: '2024-01-15 09:23', event: 'Report submitted', by: 'Ahmad Farid', icon: '📍', active: true },
  { time: '2024-01-15 10:05', event: 'Verified by 3 users', by: 'Community', icon: '✅', active: true },
  { time: '2024-01-15 14:30', event: 'Flagged as High Risk', by: 'AI System', icon: '⚠️', active: true },
  { time: '2024-01-16 08:00', event: 'Assigned to maintenance crew', by: 'Admin', icon: '🔧', active: false },
  { time: 'Pending', event: 'Resolution', by: '—', icon: '🏁', active: false },
]

export default function ReportDetailScreen({ navigate, report }: Props) {
  const r = report ?? mockReports[0]
  const [voted, setVoted] = useState<'exists' | 'resolved' | null>(null)

  return (
    <div className="flex flex-col h-full">
      {/* App bar */}
      <div
        className="flex-shrink-0 flex items-center justify-between px-5"
        style={{ height: 56, background: '#0F172A' }}
      >
        <div className="flex items-center gap-3">
          <button onClick={() => navigate('map')}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <path d="M19 12H5M12 5l-7 7 7 7" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </button>
          <span className="text-white font-bold" style={{ fontSize: 16 }}>Report Detail</span>
        </div>
        <button>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
            <circle cx="18" cy="5" r="3" /><circle cx="6" cy="12" r="3" /><circle cx="18" cy="19" r="3" />
            <line x1="8.59" y1="13.51" x2="15.42" y2="17.49" /><line x1="15.41" y1="6.51" x2="8.59" y2="10.49" />
          </svg>
        </button>
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Main image */}
        <div className="relative" style={{ height: 200 }}>
          <img src={r.imageUrl} alt={r.title} className="w-full h-full object-cover" />
          <div
            className="absolute inset-0"
            style={{ background: 'linear-gradient(to top, rgba(15,23,42,0.7) 0%, transparent 60%)' }}
          />
          <div className="absolute bottom-3 left-4 right-4">
            <SeverityBadge severity={r.severity} size="md" />
            <div className="text-white font-bold mt-1" style={{ fontSize: 17 }}>{r.title}</div>
          </div>
        </div>

        <div className="px-5 py-4 space-y-4">
          {/* Info grid */}
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: 'Category', value: r.category },
              { label: 'Status', value: r.status, capitalize: true },
              { label: 'Reported', value: r.date.split(' ')[0] },
              { label: 'Reporter', value: r.reporter },
            ].map(({ label, value }) => (
              <div
                key={label}
                className="rounded-xl p-3"
                style={{ background: '#f8fafc', border: '1px solid #E2E8F0' }}
              >
                <div style={{ fontSize: 10, color: '#94a3b8', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em' }}>{label}</div>
                <div className="font-semibold text-slate-800 mt-0.5 capitalize" style={{ fontSize: 13 }}>{value}</div>
              </div>
            ))}
          </div>

          {/* Location */}
          <div className="flex items-center gap-2 rounded-xl p-3" style={{ background: '#f0fdf4', border: '1px solid #bbf7d0' }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#22C55E" strokeWidth="2">
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" /><circle cx="12" cy="9" r="2.5" />
            </svg>
            <span style={{ fontSize: 13, color: '#1E293B', fontWeight: 500 }}>{r.location}</span>
          </div>

          {/* Description */}
          <div>
            <div className="font-bold text-slate-800 mb-2" style={{ fontSize: 13 }}>Description</div>
            <p style={{ fontSize: 13, color: '#475569', lineHeight: 1.7 }}>{r.description}</p>
          </div>

          {/* Verification */}
          <div className="rounded-2xl p-4" style={{ background: '#f8fafc', border: '1px solid #E2E8F0' }}>
            <div className="flex items-center justify-between mb-3">
              <div className="font-bold text-slate-800" style={{ fontSize: 13 }}>Community Verification</div>
              <div
                className="font-bold rounded-full"
                style={{ fontSize: 12, padding: '2px 10px', background: '#dbeafe', color: '#1d4ed8' }}
              >
                {r.verifications} verified
              </div>
            </div>
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => setVoted('exists')}
                className="flex items-center justify-center gap-2 rounded-xl font-semibold transition-all"
                style={{
                  padding: '10px',
                  fontSize: 13,
                  border: `2px solid ${voted === 'exists' ? '#F97316' : '#E2E8F0'}`,
                  background: voted === 'exists' ? '#ffedd5' : '#fff',
                  color: voted === 'exists' ? '#ea580c' : '#475569',
                }}
              >
                <span>⚠️</span> Still Exists
              </button>
              <button
                onClick={() => setVoted('resolved')}
                className="flex items-center justify-center gap-2 rounded-xl font-semibold transition-all"
                style={{
                  padding: '10px',
                  fontSize: 13,
                  border: `2px solid ${voted === 'resolved' ? '#22C55E' : '#E2E8F0'}`,
                  background: voted === 'resolved' ? '#dcfce7' : '#fff',
                  color: voted === 'resolved' ? '#15803d' : '#475569',
                }}
              >
                <span>✅</span> Resolved
              </button>
            </div>
            {voted && (
              <div className="mt-2 text-center font-medium" style={{ fontSize: 12, color: '#22C55E' }}>
                Thank you for verifying! +10 points earned.
              </div>
            )}
          </div>

          {/* Timeline */}
          <div>
            <div className="font-bold text-slate-800 mb-3" style={{ fontSize: 13 }}>Report Timeline</div>
            <div className="relative space-y-0">
              {TIMELINE.map((item, i) => (
                <div key={i} className="flex gap-3">
                  <div className="flex flex-col items-center" style={{ width: 32 }}>
                    <div
                      className="flex-shrink-0 rounded-full flex items-center justify-center"
                      style={{
                        width: 28,
                        height: 28,
                        background: item.active ? '#4361EE' : '#e2e8f0',
                        fontSize: 12,
                      }}
                    >
                      {item.icon}
                    </div>
                    {i < TIMELINE.length - 1 && (
                      <div style={{ width: 2, flex: 1, minHeight: 20, background: item.active ? '#4361EE' : '#e2e8f0', margin: '4px 0' }} />
                    )}
                  </div>
                  <div className="pb-4">
                    <div className="font-semibold text-slate-800" style={{ fontSize: 12 }}>{item.event}</div>
                    <div style={{ fontSize: 11, color: '#94a3b8' }}>{item.time} · {item.by}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
