import { useState } from 'react'
import MobileShell from '@/components/MobileShell'
import BottomNav from '@/components/BottomNav'

interface Props {
  onNavigate: (screen: string) => void
}

const severities = ['Low', 'Medium', 'High', 'Critical'] as const
const severityColors: Record<string, string> = {
  Low: '#22C55E',
  Medium: '#FACC15',
  High: '#F97316',
  Critical: '#EF4444',
}
const categories = ['Pothole', 'Road Damage', 'Traffic Signals', 'Infrastructure', 'Flooding', 'Road Markings']

export default function ReportDamage({ onNavigate }: Props) {
  const [severity, setSeverity] = useState<string>('High')
  const [category, setCategory] = useState('Pothole')
  const [desc, setDesc] = useState('')
  const [photoAdded, setPhotoAdded] = useState(false)

  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-4 px-5 flex items-center gap-3">
          <button onClick={() => onNavigate('user-map')}>
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white">
              <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
            </svg>
          </button>
          <span className="text-white font-bold text-lg">Report Road Damage</span>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] px-4 py-5 space-y-4">
          {/* Photo upload */}
          <button
            onClick={() => setPhotoAdded(!photoAdded)}
            className="w-full h-40 rounded-2xl border-2 border-dashed border-[#E2E8F0] bg-white flex flex-col items-center justify-center gap-2 hover:border-[#4361EE] transition-colors overflow-hidden"
          >
            {photoAdded ? (
              <img
                src="https://images.unsplash.com/photo-1584436055955-c41af83e4870?w=400&h=200&fit=crop&auto=format"
                alt="Road damage"
                className="w-full h-full object-cover"
              />
            ) : (
              <>
                <div className="w-12 h-12 bg-blue-50 rounded-2xl flex items-center justify-center">
                  <svg viewBox="0 0 24 24" className="w-6 h-6 fill-[#4361EE]">
                    <path d="M9 2L7.17 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2h-3.17L15 2H9zm3 15c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z" />
                  </svg>
                </div>
                <span className="text-sm font-semibold text-[#1E293B]">Tap to add photo</span>
                <span className="text-xs text-slate-400">JPG, PNG up to 10MB</span>
              </>
            )}
          </button>

          {/* GPS */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 flex items-center gap-3">
            <div className="w-10 h-10 bg-green-50 rounded-xl flex items-center justify-center shrink-0">
              <svg viewBox="0 0 24 24" className="w-5 h-5 fill-[#22C55E]">
                <path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm8.94 3A8.994 8.994 0 0 0 13 3.06V1h-2v2.06A8.994 8.994 0 0 0 3.06 11H1v2h2.06A8.994 8.994 0 0 0 11 20.94V23h2v-2.06A8.994 8.994 0 0 0 20.94 13H23v-2h-2.06zM12 19c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z" />
              </svg>
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs text-slate-400 font-medium">GPS Location Detected</p>
              <p className="text-sm font-semibold text-[#1E293B] truncate">Jalan Ampang, KL</p>
              <p className="text-xs text-slate-400">3.1585° N, 101.7123° E</p>
            </div>
            <div className="w-2 h-2 rounded-full bg-[#22C55E] animate-pulse" />
          </div>

          {/* Category */}
          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-2">Category</label>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="w-full border border-[#E2E8F0] rounded-xl bg-white px-4 py-3 text-sm text-[#1E293B] outline-none focus:border-[#4361EE] transition-colors appearance-none"
            >
              {categories.map((c) => (
                <option key={c}>{c}</option>
              ))}
            </select>
          </div>

          {/* Severity */}
          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-2">Severity Level</label>
            <div className="grid grid-cols-4 gap-2">
              {severities.map((s) => {
                const active = severity === s
                return (
                  <button
                    key={s}
                    onClick={() => setSeverity(s)}
                    className="py-2.5 rounded-xl text-xs font-semibold border-2 transition-all"
                    style={{
                      backgroundColor: active ? severityColors[s] : 'white',
                      borderColor: active ? severityColors[s] : '#E2E8F0',
                      color: active ? 'white' : severityColors[s],
                    }}
                  >
                    {s}
                  </button>
                )
              })}
            </div>
          </div>

          {/* Description */}
          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-2">Description</label>
            <textarea
              value={desc}
              onChange={(e) => setDesc(e.target.value)}
              rows={4}
              placeholder="Describe the damage in detail — size, depth, exact location, how long it has been there…"
              className="w-full border border-[#E2E8F0] rounded-xl bg-white px-4 py-3 text-sm text-[#1E293B] placeholder-slate-400 outline-none focus:border-[#4361EE] transition-colors resize-none"
            />
          </div>

          {/* Submit */}
          <button
            onClick={() => onNavigate('user-map')}
            className="w-full bg-[#4361EE] hover:bg-[#3451d4] text-white font-semibold py-3.5 rounded-xl transition-colors shadow-md shadow-[#4361EE]/30"
          >
            Submit Report
          </button>
        </div>

        <BottomNav active="user-report-damage" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
