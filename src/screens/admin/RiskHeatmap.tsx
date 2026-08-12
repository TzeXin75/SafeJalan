import { useState } from 'react'
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet'
import MobileShell from '@/components/MobileShell'
import AdminMobileNav from '@/components/AdminMobileNav'
import { reports, SEVERITY_COLORS } from '@/data/mockData'

interface Props {
  onNavigate: (screen: string) => void
}

const reportCoords: Record<string, [number, number]> = {
  'RPT-001': [3.1585, 101.7123],
  'RPT-002': [3.1073, 101.6069],
  'RPT-003': [3.0756, 101.5706],
  'RPT-004': [3.0898, 101.6673],
  'RPT-005': [3.1621, 101.7041],
  'RPT-006': [3.1781, 101.6836],
}

const hotspots = [
  { area: 'Jalan Ampang, KL', reports: 18, color: '#EF4444' },
  { area: 'Jalan PJ 5/1, PJ', reports: 12, color: '#F97316' },
  { area: 'Lebuhraya SPRINT', reports: 9, color: '#F97316' },
  { area: 'Jalan Klang Lama', reports: 6, color: '#FACC15' },
  { area: 'Jalan Duta, KL', reports: 4, color: '#22C55E' },
]

// Radius scaled by severity for heatmap effect
const SEVERITY_RADIUS: Record<string, number> = {
  Critical: 28,
  High: 22,
  Medium: 16,
  Low: 12,
}

export default function RiskHeatmap({ onNavigate }: Props) {
  const [district, setDistrict] = useState('All Districts')
  const [severity, setSeverity] = useState('All Severity')

  const filteredReports = reports.filter((r) => {
    return severity === 'All Severity' || r.severity === severity
  })

  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-4 px-5">
          <h1 className="text-white font-bold text-lg">Risk Heatmap</h1>
          <p className="text-slate-400 text-xs mt-0.5">Road damage density · Kuala Lumpur</p>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC]">
          {/* Filters */}
          <div className="px-4 py-3 flex gap-2 bg-white border-b border-[#E2E8F0]">
            <select
              value={district}
              onChange={(e) => setDistrict(e.target.value)}
              className="flex-1 border border-[#E2E8F0] rounded-xl bg-[#F8FAFC] px-3 py-2 text-sm text-slate-600 outline-none"
            >
              {['All Districts', 'Chow Kit', 'Bukit Bintang', 'Bangsar', 'Titiwangsa'].map((o) => (
                <option key={o}>{o}</option>
              ))}
            </select>
            <select
              value={severity}
              onChange={(e) => setSeverity(e.target.value)}
              className="flex-1 border border-[#E2E8F0] rounded-xl bg-[#F8FAFC] px-3 py-2 text-sm text-slate-600 outline-none"
            >
              {['All Severity', 'Critical', 'High', 'Medium', 'Low'].map((o) => (
                <option key={o}>{o}</option>
              ))}
            </select>
          </div>

          {/* Real Leaflet map */}
          <div className="relative" style={{ height: 320 }}>
            <MapContainer
              center={[3.1390, 101.6869]}
              zoom={11}
              style={{ height: '100%', width: '100%' }}
              zoomControl={true}
              attributionControl={false}
            >
              <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution="© OpenStreetMap contributors"
              />

              {filteredReports.map((r) => {
                const pos = reportCoords[r.id]
                if (!pos) return null
                return (
                  <CircleMarker
                    key={r.id}
                    center={pos}
                    radius={SEVERITY_RADIUS[r.severity] ?? 14}
                    fillColor={SEVERITY_COLORS[r.severity]}
                    color={SEVERITY_COLORS[r.severity]}
                    weight={1}
                    opacity={0.5}
                    fillOpacity={0.45}
                  >
                    <Popup>
                      <div style={{ minWidth: 150 }}>
                        <p style={{ fontWeight: 700, fontSize: 12, marginBottom: 2 }}>{r.title}</p>
                        <p style={{ fontSize: 10, color: '#64748b', marginBottom: 3 }}>{r.location}</p>
                        <span
                          style={{
                            fontSize: 10,
                            fontWeight: 700,
                            padding: '2px 8px',
                            borderRadius: 99,
                            backgroundColor: SEVERITY_COLORS[r.severity] + '20',
                            color: SEVERITY_COLORS[r.severity],
                          }}
                        >
                          {r.severity} · {r.verifications} reports
                        </span>
                      </div>
                    </Popup>
                  </CircleMarker>
                )
              })}
            </MapContainer>

            {/* Legend */}
            <div className="absolute bottom-3 left-3 z-[1000] bg-white/90 rounded-xl p-2.5 shadow-sm space-y-1.5">
              {[['Critical', '#EF4444'], ['High', '#F97316'], ['Medium', '#FACC15'], ['Low', '#22C55E']].map(([l, c]) => (
                <div key={l} className="flex items-center gap-2">
                  <div className="w-4 h-4 rounded-full opacity-60 border" style={{ backgroundColor: c, borderColor: c }} />
                  <span className="text-[10px] text-[#1E293B] font-medium">{l}</span>
                </div>
              ))}
            </div>

            {/* Attribution */}
            <div className="absolute bottom-1 right-1 z-[1000] bg-white/80 rounded px-1.5 py-0.5">
              <span className="text-[8px] text-slate-500">© OpenStreetMap</span>
            </div>
          </div>

          <div className="px-4 py-4 space-y-4">
            {/* Quick stats */}
            <div className="grid grid-cols-2 gap-2.5">
              {[
                { label: 'High Risk Areas', value: '5', color: '#EF4444' },
                { label: 'Active Incidents', value: String(filteredReports.length), color: '#F97316' },
                { label: 'Avg Resolution', value: '3.4d', color: '#4361EE' },
                { label: 'Alerts Today', value: '12', color: '#FACC15' },
              ].map((s) => (
                <div key={s.label} className="bg-white rounded-2xl border border-[#E2E8F0] p-3 shadow-sm">
                  <p className="text-xl font-bold" style={{ color: s.color }}>{s.value}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{s.label}</p>
                </div>
              ))}
            </div>

            {/* Hotspots */}
            <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
              <p className="font-semibold text-[#1E293B] text-sm mb-3">Top Hotspots</p>
              <div className="space-y-3">
                {hotspots.map((h, i) => (
                  <div key={i} className="flex items-center gap-3">
                    <span className="text-xs font-bold text-slate-400 w-4 shrink-0">{i + 1}</span>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-[#1E293B] truncate">{h.area}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <div className="flex-1 bg-[#F1F5F9] rounded-full h-1.5">
                          <div
                            className="h-1.5 rounded-full"
                            style={{ width: `${(h.reports / 18) * 100}%`, backgroundColor: h.color }}
                          />
                        </div>
                        <span className="text-xs text-slate-400 shrink-0">{h.reports}</span>
                      </div>
                    </div>
                    <div className="w-2 h-2 rounded-full shrink-0" style={{ backgroundColor: h.color }} />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        <AdminMobileNav active="admin-heatmap" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
