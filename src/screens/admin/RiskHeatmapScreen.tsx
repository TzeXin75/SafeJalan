import { useState } from 'react'
import AdminLayout from '../../components/AdminLayout'

interface Props {
  navigate: (screen: string) => void
  activeScreen: string
  onLogout: () => void
}

const HOTSPOTS = [
  { name: 'Jalan Ampang Corridor', district: 'Ampang', reports: 38, risk: 'critical' as const },
  { name: 'Federal Highway KM 8–14', district: 'Subang', reports: 31, risk: 'high' as const },
  { name: 'Jalan Cheras Batu 5–9', district: 'Cheras', reports: 24, risk: 'high' as const },
  { name: 'Jalan Duta Underpass', district: 'Duta', reports: 18, risk: 'medium' as const },
  { name: 'Jalan PJ Lama', district: 'PJ', reports: 12, risk: 'low' as const },
]

const RISK_COLOR: Record<string, string> = {
  critical: '#EF4444',
  high: '#F97316',
  medium: '#FACC15',
  low: '#22C55E',
}

const RISK_BG: Record<string, string> = {
  critical: '#fee2e2',
  high: '#ffedd5',
  medium: '#fef9c3',
  low: '#dcfce7',
}

const MARKERS = [
  { top: '30%', left: '38%', size: 36, color: '#EF444488', severity: 'critical', count: 38 },
  { top: '50%', left: '25%', size: 28, color: '#F9731666', severity: 'high', count: 31 },
  { top: '62%', left: '58%', size: 24, color: '#F9731655', severity: 'high', count: 24 },
  { top: '22%', left: '65%', size: 20, color: '#FACC1544', severity: 'medium', count: 18 },
  { top: '70%', left: '35%', size: 16, color: '#22C55E33', severity: 'low', count: 12 },
]

export default function RiskHeatmapScreen({ navigate, activeScreen, onLogout }: Props) {
  const [dateFilter, setDateFilter] = useState('30d')
  const [districtFilter, setDistrictFilter] = useState('all')

  return (
    <AdminLayout navigate={navigate} activeScreen={activeScreen} onLogout={onLogout}>
      <div>
        <div className="mb-4">
          <div className="font-bold text-slate-800" style={{ fontSize: 22 }}>Risk Heatmap</div>
          <div style={{ color: '#64748b', fontSize: 13, marginTop: 2 }}>Road damage density across monitored areas</div>
        </div>

        <div className="flex gap-5">
          {/* Map area (70%) */}
          <div className="flex-1 min-w-0 space-y-4">
            {/* Filters */}
            <div className="flex items-center gap-3 flex-wrap">
              {[
                { value: '7d', label: '7 Days' },
                { value: '30d', label: '30 Days' },
                { value: '90d', label: '3 Months' },
                { value: '1y', label: '1 Year' },
              ].map((f) => (
                <button
                  key={f.value}
                  onClick={() => setDateFilter(f.value)}
                  className="rounded-lg font-semibold transition-colors"
                  style={{
                    padding: '7px 14px',
                    fontSize: 12,
                    background: dateFilter === f.value ? '#4361EE' : '#fff',
                    color: dateFilter === f.value ? '#fff' : '#64748b',
                    border: `1.5px solid ${dateFilter === f.value ? '#4361EE' : '#E2E8F0'}`,
                  }}
                >
                  {f.label}
                </button>
              ))}
              <select
                value={districtFilter}
                onChange={(e) => setDistrictFilter(e.target.value)}
                className="outline-none font-medium"
                style={{
                  padding: '7px 28px 7px 12px',
                  border: '1.5px solid #E2E8F0',
                  borderRadius: 10,
                  fontSize: 12,
                  background: '#fff',
                  color: '#475569',
                }}
              >
                <option value="all">All Districts</option>
                {['Ampang', 'Subang', 'Cheras', 'Duta', 'PJ'].map((d) => (
                  <option key={d} value={d}>{d}</option>
                ))}
              </select>
            </div>

            {/* Map */}
            <div
              className="relative rounded-2xl overflow-hidden"
              style={{ height: 480, background: '#e8f0e8', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
            >
              {/* Map grid background */}
              <div
                className="absolute inset-0"
                style={{
                  backgroundImage: `
                    linear-gradient(rgba(200,220,200,0.6) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(200,220,200,0.6) 1px, transparent 1px)
                  `,
                  backgroundSize: '60px 60px',
                }}
              />
              {/* Roads */}
              <svg className="absolute inset-0 w-full h-full" viewBox="0 0 800 480" preserveAspectRatio="none">
                <rect x="0" y="210" width="800" height="18" fill="#fff" opacity="0.8" />
                <rect x="320" y="0" width="18" height="480" fill="#fff" opacity="0.8" />
                <rect x="0" y="320" width="800" height="12" fill="#f3f4f6" opacity="0.7" />
                <rect x="180" y="0" width="10" height="480" fill="#f3f4f6" opacity="0.6" />
                <rect x="520" y="0" width="10" height="480" fill="#f3f4f6" opacity="0.6" />
                <path d="M0 0 L800 480" stroke="#fff" strokeWidth="12" opacity="0.35" />
                <path d="M0 480 L800 0" stroke="#f3f4f6" strokeWidth="8" opacity="0.3" />
                {/* Water */}
                <path d="M 550 0 Q 580 120 570 240 Q 560 360 590 480" stroke="#93c5fd" strokeWidth="18" fill="none" opacity="0.6" />
                {/* Parks */}
                <rect x="60" y="60" width="100" height="80" fill="#86efac" opacity="0.4" rx="8" />
                <rect x="620" y="360" width="90" height="70" fill="#86efac" opacity="0.4" rx="8" />
                <rect x="380" y="30" width="70" height="50" fill="#86efac" opacity="0.35" rx="6" />
              </svg>

              {/* Heatmap blobs */}
              {MARKERS.map((m, i) => (
                <div
                  key={i}
                  className="absolute transform -translate-x-1/2 -translate-y-1/2 rounded-full"
                  style={{
                    top: m.top,
                    left: m.left,
                    width: m.size * 3.5,
                    height: m.size * 3.5,
                    background: m.color,
                    filter: 'blur(16px)',
                  }}
                />
              ))}

              {/* Markers */}
              {MARKERS.map((m, i) => (
                <div
                  key={`dot-${i}`}
                  className="absolute transform -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white flex items-center justify-center font-bold text-white shadow-lg"
                  style={{
                    top: m.top,
                    left: m.left,
                    width: m.size,
                    height: m.size,
                    background: RISK_COLOR[m.severity],
                    fontSize: m.size > 28 ? 12 : 9,
                    boxShadow: `0 4px 12px ${RISK_COLOR[m.severity]}88`,
                  }}
                >
                  {m.count}
                </div>
              ))}

              {/* Legend */}
              <div
                className="absolute bottom-4 left-4 rounded-xl p-3"
                style={{ background: 'rgba(255,255,255,0.92)', border: '1px solid #E2E8F0', backdropFilter: 'blur(8px)' }}
              >
                <div className="font-bold text-slate-800 mb-2" style={{ fontSize: 11 }}>RISK LEVEL</div>
                {[
                  { label: 'Critical', color: '#EF4444' },
                  { label: 'High', color: '#F97316' },
                  { label: 'Medium', color: '#FACC15' },
                  { label: 'Low', color: '#22C55E' },
                ].map((l) => (
                  <div key={l.label} className="flex items-center gap-2 mb-1">
                    <div className="rounded-sm" style={{ width: 12, height: 12, background: l.color, opacity: 0.7 }} />
                    <span style={{ fontSize: 11, color: '#475569' }}>{l.label}</span>
                  </div>
                ))}
              </div>

              {/* Attribution */}
              <div
                className="absolute bottom-3 right-3 rounded"
                style={{ fontSize: 10, color: '#64748b', background: 'rgba(255,255,255,0.8)', padding: '2px 6px' }}
              >
                SafeJalan Risk Analysis • KL Metro Area
              </div>
            </div>
          </div>

          {/* Right panel */}
          <div className="flex-shrink-0 space-y-4" style={{ width: 280 }}>
            {/* Summary stats */}
            {[
              { label: 'High-Risk Zones', value: '7', color: '#EF4444', bg: '#fee2e2', icon: '🔴' },
              { label: 'Active Incidents', value: '142', color: '#F97316', bg: '#ffedd5', icon: '⚠️' },
              { label: 'Avg Resolution', value: '3.2 days', color: '#4361EE', bg: '#eff6ff', icon: '⏱' },
              { label: 'Resolved This Month', value: '89', color: '#22C55E', bg: '#dcfce7', icon: '✅' },
            ].map((s) => (
              <div
                key={s.label}
                className="flex items-center gap-3 rounded-2xl p-4"
                style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
              >
                <div
                  className="flex-shrink-0 rounded-xl flex items-center justify-center"
                  style={{ width: 40, height: 40, background: s.bg, fontSize: 20 }}
                >
                  {s.icon}
                </div>
                <div>
                  <div style={{ fontSize: 11, color: '#94a3b8', fontWeight: 600 }}>{s.label}</div>
                  <div className="font-bold" style={{ fontSize: 20, color: s.color }}>{s.value}</div>
                </div>
              </div>
            ))}

            {/* Top hotspots */}
            <div
              className="rounded-2xl overflow-hidden"
              style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
            >
              <div className="px-4 py-3" style={{ borderBottom: '1px solid #E2E8F0' }}>
                <div className="font-bold text-slate-800" style={{ fontSize: 14 }}>Top Risk Areas</div>
              </div>
              <div className="divide-y divide-slate-100">
                {HOTSPOTS.map((h, i) => (
                  <div key={h.name} className="flex items-center gap-3 px-4 py-3">
                    <div
                      className="flex-shrink-0 rounded-full flex items-center justify-center font-bold text-white"
                      style={{ width: 26, height: 26, background: RISK_COLOR[h.risk], fontSize: 11 }}
                    >
                      {i + 1}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-semibold text-slate-800 truncate" style={{ fontSize: 12 }}>{h.name}</div>
                      <div style={{ fontSize: 10, color: '#94a3b8' }}>{h.district} · {h.reports} reports</div>
                    </div>
                    <span
                      style={{
                        fontSize: 10,
                        fontWeight: 700,
                        padding: '2px 7px',
                        borderRadius: 20,
                        background: RISK_BG[h.risk],
                        color: RISK_COLOR[h.risk],
                        textTransform: 'capitalize',
                      }}
                    >
                      {h.risk}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
