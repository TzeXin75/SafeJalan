import { useState } from 'react'
import BottomNav from '../../components/BottomNav'
import { connectivityReports } from '../../data/mockData'

interface Props {
  navigate: (screen: string) => void
}

const CARRIERS = ['Celcom', 'Maxis', 'Digi', 'U Mobile', 'Yes 5G', 'Unifi Mobile']

export default function ConnectivityScreen({ navigate }: Props) {
  const [type, setType] = useState<'poor-signal' | 'no-wifi' | null>(null)
  const [strength, setStrength] = useState(2)
  const [carrier, setCarrier] = useState('')
  const [notes, setNotes] = useState('')
  const [submitted, setSubmitted] = useState(false)

  const handleSubmit = () => {
    setSubmitted(true)
    setTimeout(() => setSubmitted(false), 2000)
  }

  return (
    <div className="flex flex-col h-full">
      {/* App bar */}
      <div
        className="flex-shrink-0 flex items-center gap-3 px-5"
        style={{ height: 56, background: '#0F172A' }}
      >
        <span className="text-white font-bold" style={{ fontSize: 16 }}>Connectivity Report</span>
      </div>

      <div className="flex-1 overflow-y-auto px-5 py-4 space-y-5">
        {/* Type selection */}
        <div>
          <div className="font-bold text-slate-800 mb-3" style={{ fontSize: 13 }}>Issue Type</div>
          <div className="grid grid-cols-2 gap-3">
            {[
              {
                id: 'poor-signal' as const,
                label: 'Poor Signal',
                desc: 'Weak cellular coverage',
                icon: (
                  <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M1 6s4-6 11-6 11 6 11 6" /><path d="M5 10s2.5-4 7-4 7 4 7 4" strokeLinecap="round" />
                    <circle cx="12" cy="14" r="2" /><path d="M12 16v5" strokeLinecap="round" />
                  </svg>
                ),
              },
              {
                id: 'no-wifi' as const,
                label: 'No Wi-Fi',
                desc: 'No wireless coverage',
                icon: (
                  <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M5 12.55a11 11 0 0114.08 0M1.42 9a16 16 0 0121.16 0M8.53 16.11a6 6 0 016.95 0" strokeLinecap="round" />
                    <circle cx="12" cy="20" r="1" fill="currentColor" />
                    <line x1="2" y1="2" x2="22" y2="22" strokeLinecap="round" />
                  </svg>
                ),
              },
            ].map((opt) => (
              <button
                key={opt.id}
                onClick={() => setType(type === opt.id ? null : opt.id)}
                className="flex flex-col items-center gap-2 rounded-2xl p-4 transition-all"
                style={{
                  border: `2px solid ${type === opt.id ? '#4361EE' : '#E2E8F0'}`,
                  background: type === opt.id ? '#eff6ff' : '#fff',
                  color: type === opt.id ? '#4361EE' : '#94a3b8',
                }}
              >
                {opt.icon}
                <div>
                  <div className="font-bold" style={{ fontSize: 13, color: type === opt.id ? '#4361EE' : '#1E293B' }}>{opt.label}</div>
                  <div style={{ fontSize: 11, color: '#94a3b8', marginTop: 2 }}>{opt.desc}</div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Signal strength */}
        {type === 'poor-signal' && (
          <div>
            <div className="flex items-center justify-between mb-2">
              <div className="font-bold text-slate-800" style={{ fontSize: 13 }}>Signal Strength</div>
              <div className="flex gap-1">
                {[1, 2, 3, 4, 5].map((i) => (
                  <div
                    key={i}
                    style={{
                      width: 6,
                      height: 6 + i * 4,
                      borderRadius: 2,
                      background: i <= strength ? '#4361EE' : '#E2E8F0',
                    }}
                  />
                ))}
              </div>
            </div>
            <input
              type="range"
              min={1}
              max={5}
              value={strength}
              onChange={(e) => setStrength(Number(e.target.value))}
              className="w-full"
              style={{ accentColor: '#4361EE' }}
            />
            <div className="flex justify-between" style={{ fontSize: 11, color: '#94a3b8' }}>
              <span>Very Weak</span><span>Excellent</span>
            </div>
          </div>
        )}

        {/* Carrier */}
        <div>
          <label className="block font-bold text-slate-800 mb-2" style={{ fontSize: 13 }}>Mobile Carrier</label>
          <div className="relative">
            <select
              value={carrier}
              onChange={(e) => setCarrier(e.target.value)}
              className="w-full appearance-none outline-none font-medium"
              style={{
                padding: '12px 40px 12px 14px',
                border: '1.5px solid #E2E8F0',
                borderRadius: 12,
                fontSize: 14,
                background: '#f8fafc',
                color: carrier ? '#1E293B' : '#94a3b8',
              }}
            >
              <option value="">Select carrier...</option>
              {CARRIERS.map((c) => <option key={c}>{c}</option>)}
            </select>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" strokeWidth="2" className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none">
              <path d="M6 9l6 6 6-6" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </div>
        </div>

        {/* Notes */}
        <div>
          <label className="block font-bold text-slate-800 mb-2" style={{ fontSize: 13 }}>Additional Notes</label>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Describe the connectivity issue — tunnel, basement, specific area..."
            rows={3}
            className="w-full outline-none resize-none text-slate-800"
            style={{
              padding: '12px 14px',
              border: '1.5px solid #E2E8F0',
              borderRadius: 12,
              fontSize: 13,
              background: '#f8fafc',
              lineHeight: 1.6,
            }}
            onFocus={(e) => (e.currentTarget.style.borderColor = '#4361EE')}
            onBlur={(e) => (e.currentTarget.style.borderColor = '#E2E8F0')}
          />
        </div>

        {/* Submit */}
        {submitted ? (
          <div className="flex items-center justify-center gap-2 rounded-xl py-4" style={{ background: '#dcfce7' }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#22C55E" strokeWidth="2.5">
              <path d="M20 6L9 17l-5-5" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
            <span className="font-bold" style={{ color: '#15803d', fontSize: 14 }}>Gap Reported Successfully!</span>
          </div>
        ) : (
          <button
            onClick={handleSubmit}
            className="w-full font-bold text-white rounded-xl transition-transform active:scale-95"
            style={{ padding: '14px', background: '#4361EE', fontSize: 15, boxShadow: '0 4px 14px rgba(67,97,238,0.4)' }}
          >
            Report Connectivity Gap
          </button>
        )}

        {/* Recent reports */}
        <div>
          <div className="font-bold text-slate-800 mb-3" style={{ fontSize: 13 }}>Recent Reports Nearby</div>
          <div className="space-y-2">
            {connectivityReports.map((r) => (
              <div
                key={r.id}
                className="flex items-center gap-3 rounded-xl p-3"
                style={{ background: '#fff', border: '1px solid #E2E8F0' }}
              >
                <div
                  className="flex-shrink-0 rounded-full flex items-center justify-center"
                  style={{ width: 36, height: 36, background: r.type === 'poor-signal' ? '#dbeafe' : '#fef3c7' }}
                >
                  <span style={{ fontSize: 16 }}>{r.type === 'poor-signal' ? '📶' : '📵'}</span>
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-slate-800" style={{ fontSize: 13 }}>
                    {r.type === 'poor-signal' ? 'Poor Signal' : 'No Wi-Fi'} · {r.carrier}
                  </div>
                  <div style={{ fontSize: 11, color: '#94a3b8' }}>{r.location}</div>
                </div>
                <div style={{ fontSize: 11, color: '#94a3b8' }}>{r.date.split(' ')[0]}</div>
              </div>
            ))}
          </div>
        </div>
        <div style={{ height: 8 }} />
      </div>

      <BottomNav active="connectivity" navigate={navigate} />
    </div>
  )
}
