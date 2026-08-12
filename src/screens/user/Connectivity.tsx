import { useState } from 'react'
import MobileShell from '@/components/MobileShell'
import BottomNav from '@/components/BottomNav'
import { connectivityReports } from '@/data/mockData'

interface Props {
  onNavigate: (screen: string) => void
}

export default function Connectivity({ onNavigate }: Props) {
  const [type, setType] = useState<'signal' | 'wifi' | null>(null)
  const [signal, setSignal] = useState(2)
  const [carrier, setCarrier] = useState('')
  const [notes, setNotes] = useState('')

  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-4 px-5">
          <h1 className="text-white font-bold text-lg">Connectivity Issues</h1>
          <p className="text-slate-400 text-xs mt-0.5">Help map network dead zones</p>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] px-4 py-5 space-y-5">
          {/* Type selection */}
          <div>
            <p className="text-xs font-semibold text-[#1E293B] mb-3">Issue Type</p>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setType(type === 'signal' ? null : 'signal')}
                className={`flex flex-col items-center gap-2 py-5 rounded-2xl border-2 transition-all ${
                  type === 'signal'
                    ? 'border-[#4361EE] bg-[#4361EE]/5'
                    : 'border-[#E2E8F0] bg-white'
                }`}
              >
                <svg viewBox="0 0 24 24" className={`w-8 h-8 ${type === 'signal' ? 'fill-[#4361EE]' : 'fill-slate-400'}`}>
                  <path d="M1 9l2 2c4.97-4.97 13.03-4.97 18 0l2-2C16.93 2.93 7.08 2.93 1 9zm8 8l3 3 3-3c-1.65-1.66-4.34-1.66-6 0zm-4-4 2 2c2.76-2.76 7.24-2.76 10 0l2-2C15.14 9.14 8.87 9.14 5 13z" />
                </svg>
                <span className={`text-sm font-semibold ${type === 'signal' ? 'text-[#4361EE]' : 'text-[#1E293B]'}`}>
                  Poor Signal
                </span>
                <span className="text-xs text-slate-400">Mobile data issue</span>
              </button>

              <button
                onClick={() => setType(type === 'wifi' ? null : 'wifi')}
                className={`flex flex-col items-center gap-2 py-5 rounded-2xl border-2 transition-all ${
                  type === 'wifi'
                    ? 'border-[#4361EE] bg-[#4361EE]/5'
                    : 'border-[#E2E8F0] bg-white'
                }`}
              >
                <svg viewBox="0 0 24 24" className={`w-8 h-8 ${type === 'wifi' ? 'fill-[#4361EE]' : 'fill-slate-400'}`}>
                  <path d="M24 8.98C21.34 6.36 17.67 4.75 13.63 4.75c-4.04 0-7.71 1.61-10.37 4.23L.62 6.35C3.91 3.18 8.39 1.25 13.38 1.25c5.24 0 9.95 2.15 13.31 5.59L24 8.98zm-4.59 4.58c-1.56-1.54-3.72-2.5-6.12-2.5-2.4 0-4.56.96-6.13 2.5L5.53 11.4c1.95-1.86 4.62-3.01 7.6-3.01 2.98 0 5.65 1.15 7.59 3.01l-1.31 1.16zm-4.7 4.88l-2.26-2.36c.37-.33.88-.53 1.42-.53.54 0 1.05.2 1.43.53l-2.28 2.36z" />
                </svg>
                <span className={`text-sm font-semibold ${type === 'wifi' ? 'text-[#4361EE]' : 'text-[#1E293B]'}`}>
                  No Wi-Fi
                </span>
                <span className="text-xs text-slate-400">Public hotspot issue</span>
              </button>
            </div>
          </div>

          {/* Signal strength */}
          {type === 'signal' && (
            <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4">
              <label className="block text-xs font-semibold text-[#1E293B] mb-3">
                Signal Strength: <span className="text-[#4361EE]">{['None', 'Very Weak', 'Weak', 'Fair', 'Good'][signal]}</span>
              </label>
              <input
                type="range"
                min={0}
                max={4}
                value={signal}
                onChange={(e) => setSignal(Number(e.target.value))}
                className="w-full accent-[#4361EE]"
              />
              <div className="flex justify-between text-xs text-slate-400 mt-1">
                <span>None</span>
                <span>Good</span>
              </div>
            </div>
          )}

          {/* Carrier */}
          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-2">Network Carrier</label>
            <div className="flex items-center border border-[#E2E8F0] rounded-xl bg-white px-3 gap-2 focus-within:border-[#4361EE] transition-colors">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
                <path d="M17 1.01L7 1c-1.1 0-2 .9-2 2v18c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2V3c0-1.1-.9-1.99-2-1.99zM17 19H7V5h10v14z" />
              </svg>
              <input
                type="text"
                value={carrier}
                onChange={(e) => setCarrier(e.target.value)}
                placeholder="e.g. Celcom, Maxis, Digi, U Mobile"
                className="flex-1 py-3 text-sm bg-transparent outline-none text-[#1E293B] placeholder-slate-400"
              />
            </div>
          </div>

          {/* GPS */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-3 flex items-center gap-3">
            <div className="w-9 h-9 bg-green-50 rounded-xl flex items-center justify-center shrink-0">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-[#22C55E]">
                <path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm8.94 3A8.994 8.994 0 0 0 13 3.06V1h-2v2.06A8.994 8.994 0 0 0 3.06 11H1v2h2.06A8.994 8.994 0 0 0 11 20.94V23h2v-2.06A8.994 8.994 0 0 0 20.94 13H23v-2h-2.06z" />
              </svg>
            </div>
            <div>
              <p className="text-xs text-slate-400">Location</p>
              <p className="text-sm font-semibold text-[#1E293B]">Bukit Bintang, KL</p>
            </div>
          </div>

          {/* Notes */}
          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-2">Additional Notes</label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={3}
              placeholder="When did you notice this issue? Any other details…"
              className="w-full border border-[#E2E8F0] rounded-xl bg-white px-4 py-3 text-sm text-[#1E293B] placeholder-slate-400 outline-none focus:border-[#4361EE] transition-colors resize-none"
            />
          </div>

          <button
            onClick={() => onNavigate('user-map')}
            className="w-full bg-[#4361EE] hover:bg-[#3451d4] text-white font-semibold py-3.5 rounded-xl transition-colors shadow-md shadow-[#4361EE]/30"
          >
            Report Gap
          </button>

          {/* Recent reports */}
          <div>
            <p className="text-xs font-semibold text-[#1E293B] mb-3">Recent Connectivity Reports</p>
            <div className="space-y-2">
              {connectivityReports.map((c, i) => (
                <div key={i} className="bg-white rounded-xl border border-[#E2E8F0] p-3 flex items-center justify-between">
                  <div>
                    <p className="text-sm font-semibold text-[#1E293B]">{c.area}</p>
                    <p className="text-xs text-slate-400">{c.carrier} · {c.type}</p>
                  </div>
                  <span className="text-xs text-slate-400">{c.time}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <BottomNav active="user-connectivity" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
