import { useState } from 'react'

interface Props {
  navigate: (screen: string) => void
}

const CATEGORIES = ['Pothole', 'Road Crack', 'Flooding', 'Missing Signage', 'Damaged Barrier', 'Other']
const SEVERITIES = [
  { id: 'low', label: 'Low', color: '#22C55E', bg: '#dcfce7' },
  { id: 'medium', label: 'Medium', color: '#d97706', bg: '#fef9c3' },
  { id: 'high', label: 'High', color: '#ea580c', bg: '#ffedd5' },
  { id: 'critical', label: 'Critical', color: '#dc2626', bg: '#fee2e2' },
]

export default function ReportDamageScreen({ navigate }: Props) {
  const [severity, setSeverity] = useState<string>('')
  const [category, setCategory] = useState<string>('')
  const [description, setDescription] = useState('')
  const [photoAdded, setPhotoAdded] = useState(false)
  const [submitted, setSubmitted] = useState(false)

  const handleSubmit = () => {
    setSubmitted(true)
    setTimeout(() => navigate('map'), 1800)
  }

  if (submitted) {
    return (
      <div className="flex flex-col items-center justify-center h-full px-6 text-center gap-4">
        <div
          className="rounded-full flex items-center justify-center"
          style={{ width: 80, height: 80, background: '#dcfce7' }}
        >
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#22C55E" strokeWidth="2.5">
            <path d="M20 6L9 17l-5-5" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </div>
        <div>
          <div className="font-bold text-slate-800" style={{ fontSize: 20 }}>Report Submitted!</div>
          <div style={{ color: '#64748b', fontSize: 13, marginTop: 4 }}>Thank you for helping keep our roads safe. Your report is being reviewed.</div>
        </div>
        <div
          className="rounded-full font-semibold"
          style={{ padding: '8px 20px', background: '#dbeafe', color: '#1d4ed8', fontSize: 13 }}
        >
          +50 Points Earned 🎉
        </div>
      </div>
    )
  }

  return (
    <div className="flex flex-col h-full">
      {/* App bar */}
      <div
        className="flex-shrink-0 flex items-center gap-3 px-5"
        style={{ height: 56, background: '#0F172A' }}
      >
        <button onClick={() => navigate('map')}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
            <path d="M19 12H5M12 5l-7 7 7 7" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        <span className="text-white font-bold" style={{ fontSize: 16 }}>Report Road Damage</span>
      </div>

      <div className="flex-1 overflow-y-auto px-5 py-4 space-y-4">
        {/* Photo upload */}
        <div>
          <label className="block font-bold text-slate-800 mb-2" style={{ fontSize: 13 }}>Photo Evidence</label>
          {photoAdded ? (
            <div className="relative rounded-2xl overflow-hidden" style={{ height: 160 }}>
              <img
                src="https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=400&h=160&fit=crop"
                alt="Road damage"
                className="w-full h-full object-cover"
              />
              <button
                onClick={() => setPhotoAdded(false)}
                className="absolute top-2 right-2 rounded-full flex items-center justify-center"
                style={{ width: 28, height: 28, background: 'rgba(0,0,0,0.6)' }}
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5">
                  <path d="M18 6L6 18M6 6l12 12" strokeLinecap="round" />
                </svg>
              </button>
            </div>
          ) : (
            <button
              onClick={() => setPhotoAdded(true)}
              className="w-full flex flex-col items-center justify-center gap-3 rounded-2xl border-2 border-dashed transition-colors"
              style={{ height: 140, borderColor: '#cbd5e1', background: '#f8fafc' }}
            >
              <div
                className="rounded-2xl flex items-center justify-center"
                style={{ width: 52, height: 52, background: '#eff6ff' }}
              >
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#4361EE" strokeWidth="2">
                  <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" />
                  <circle cx="12" cy="13" r="4" />
                </svg>
              </div>
              <div>
                <div className="font-semibold" style={{ fontSize: 13, color: '#4361EE' }}>Take Photo or Upload</div>
                <div style={{ fontSize: 11, color: '#94a3b8', marginTop: 2 }}>Tap to add photo evidence</div>
              </div>
            </button>
          )}
        </div>

        {/* GPS Location */}
        <div
          className="flex items-center gap-3 rounded-2xl p-4"
          style={{ background: '#f0fdf4', border: '1px solid #bbf7d0' }}
        >
          <div
            className="flex-shrink-0 rounded-full flex items-center justify-center"
            style={{ width: 40, height: 40, background: '#22C55E' }}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5">
              <circle cx="12" cy="11" r="3" />
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" />
            </svg>
          </div>
          <div className="flex-1">
            <div className="font-semibold" style={{ fontSize: 12, color: '#15803d' }}>GPS Location Detected</div>
            <div className="font-bold text-slate-800" style={{ fontSize: 13, marginTop: 1 }}>Jalan Ampang, KL 50450</div>
            <div style={{ fontSize: 11, color: '#64748b' }}>3.1578° N, 101.7155° E · Accuracy ±5m</div>
          </div>
          <button style={{ color: '#4361EE', fontSize: 12, fontWeight: 600 }}>Edit</button>
        </div>

        {/* Category */}
        <div>
          <label className="block font-bold text-slate-800 mb-2" style={{ fontSize: 13 }}>Category</label>
          <div className="relative">
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="w-full appearance-none outline-none font-medium"
              style={{
                padding: '12px 40px 12px 14px',
                border: '1.5px solid #E2E8F0',
                borderRadius: 12,
                fontSize: 14,
                background: '#f8fafc',
                color: category ? '#1E293B' : '#94a3b8',
              }}
            >
              <option value="">Select category...</option>
              {CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
            </select>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" strokeWidth="2" className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none">
              <path d="M6 9l6 6 6-6" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </div>
        </div>

        {/* Severity */}
        <div>
          <label className="block font-bold text-slate-800 mb-2" style={{ fontSize: 13 }}>Severity Level</label>
          <div className="grid grid-cols-4 gap-2">
            {SEVERITIES.map((s) => (
              <button
                key={s.id}
                onClick={() => setSeverity(s.id)}
                className="rounded-xl py-2.5 font-bold transition-all"
                style={{
                  fontSize: 12,
                  border: `2px solid ${severity === s.id ? s.color : '#E2E8F0'}`,
                  background: severity === s.id ? s.bg : '#fff',
                  color: severity === s.id ? s.color : '#94a3b8',
                  transform: severity === s.id ? 'scale(1.05)' : 'scale(1)',
                }}
              >
                {s.label}
              </button>
            ))}
          </div>
        </div>

        {/* Description */}
        <div>
          <label className="block font-bold text-slate-800 mb-2" style={{ fontSize: 13 }}>Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Describe the road damage in detail — size, depth, danger level..."
            rows={4}
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
          <div className="text-right mt-1" style={{ fontSize: 11, color: '#94a3b8' }}>
            {description.length}/500
          </div>
        </div>

        {/* Submit */}
        <button
          onClick={handleSubmit}
          className="w-full font-bold text-white rounded-xl transition-transform active:scale-95"
          style={{ padding: '14px', background: '#4361EE', fontSize: 15, boxShadow: '0 4px 14px rgba(67,97,238,0.4)' }}
        >
          Submit Report
        </button>
        <div style={{ height: 8 }} />
      </div>
    </div>
  )
}
