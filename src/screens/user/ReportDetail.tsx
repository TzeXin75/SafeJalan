import { useState } from 'react'
import MobileShell from '@/components/MobileShell'
import BottomNav from '@/components/BottomNav'
import { reports } from '@/data/mockData'
import { SeverityBadge, StatusBadge } from '@/components/Badge'

interface Props {
  onNavigate: (screen: string) => void
}

const timeline = [
  { label: 'Report Submitted', time: '20 Jul 2026 · 09:14', done: true },
  { label: 'Under Review', time: '20 Jul 2026 · 10:30', done: true },
  { label: 'Verified by Admin', time: '20 Jul 2026 · 14:00', done: true },
  { label: 'Forwarded to JKR', time: '21 Jul 2026 · 08:00', done: false },
  { label: 'Resolved', time: 'Pending', done: false },
]

export default function ReportDetail({ onNavigate }: Props) {
  const r = reports[0]
  const [voted, setVoted] = useState<'exists' | 'resolved' | null>(null)

  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header image */}
        <div className="relative">
          <img
            src={r.imageUrl}
            alt={r.title}
            className="w-full h-44 object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
          <button
            onClick={() => onNavigate('user-map')}
            className="absolute top-12 left-4 w-8 h-8 bg-black/40 rounded-xl flex items-center justify-center"
          >
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white">
              <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
            </svg>
          </button>
          <div className="absolute bottom-3 left-4 right-4">
            <p className="text-white font-bold text-lg leading-tight line-clamp-2">{r.title}</p>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] px-4 py-4 space-y-4">
          {/* Info card */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 space-y-3">
            <div className="flex items-center gap-2 flex-wrap">
              <SeverityBadge severity={r.severity} />
              <StatusBadge status={r.status} />
              <span className="text-xs text-slate-400 ml-auto">{r.date}</span>
            </div>

            <div className="grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
              <div>
                <p className="text-xs text-slate-400">Category</p>
                <p className="font-semibold text-[#1E293B]">{r.category}</p>
              </div>
              <div>
                <p className="text-xs text-slate-400">Reporter</p>
                <p className="font-semibold text-[#1E293B]">{r.reporter}</p>
              </div>
              <div className="col-span-2">
                <p className="text-xs text-slate-400">Location</p>
                <p className="font-semibold text-[#1E293B]">{r.location}</p>
              </div>
            </div>

            <p className="text-sm text-slate-600 leading-relaxed border-t border-[#E2E8F0] pt-3">{r.description}</p>
          </div>

          {/* Verification */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4">
            <div className="flex items-center justify-between mb-3">
              <p className="font-semibold text-[#1E293B] text-sm">Community Verification</p>
              <span className="text-xs text-slate-400">{r.verifications} votes</span>
            </div>

            <div className="grid grid-cols-2 gap-2 mb-4">
              <button
                onClick={() => setVoted('exists')}
                className={`py-2.5 rounded-xl text-sm font-semibold border-2 transition-all ${
                  voted === 'exists'
                    ? 'bg-[#F97316] border-[#F97316] text-white'
                    : 'border-[#E2E8F0] text-[#F97316] bg-white'
                }`}
              >
                ⚠ Still Exists
              </button>
              <button
                onClick={() => setVoted('resolved')}
                className={`py-2.5 rounded-xl text-sm font-semibold border-2 transition-all ${
                  voted === 'resolved'
                    ? 'bg-[#22C55E] border-[#22C55E] text-white'
                    : 'border-[#E2E8F0] text-[#22C55E] bg-white'
                }`}
              >
                ✓ Resolved
              </button>
            </div>

            {/* Stats bar */}
            <div className="flex rounded-lg overflow-hidden h-2">
              <div className="bg-[#F97316]" style={{ width: '75%' }} />
              <div className="bg-[#22C55E]" style={{ width: '25%' }} />
            </div>
            <div className="flex justify-between mt-1 text-xs text-slate-400">
              <span>Still Exists (11)</span>
              <span>Resolved (3)</span>
            </div>
          </div>

          {/* Timeline */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4">
            <p className="font-semibold text-[#1E293B] text-sm mb-4">Report Timeline</p>
            <div className="space-y-3">
              {timeline.map((t, i) => (
                <div key={i} className="flex gap-3 items-start">
                  <div className="flex flex-col items-center">
                    <div
                      className={`w-4 h-4 rounded-full flex items-center justify-center shrink-0 ${
                        t.done ? 'bg-[#4361EE]' : 'bg-[#E2E8F0]'
                      }`}
                    >
                      {t.done && (
                        <svg viewBox="0 0 24 24" className="w-2.5 h-2.5 fill-white">
                          <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                        </svg>
                      )}
                    </div>
                    {i < timeline.length - 1 && (
                      <div className={`w-0.5 h-5 mt-1 ${t.done ? 'bg-[#4361EE]/30' : 'bg-[#E2E8F0]'}`} />
                    )}
                  </div>
                  <div className="flex-1 pb-1">
                    <p className={`text-sm font-semibold ${t.done ? 'text-[#1E293B]' : 'text-slate-400'}`}>
                      {t.label}
                    </p>
                    <p className="text-xs text-slate-400">{t.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        <BottomNav active="user-map" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
