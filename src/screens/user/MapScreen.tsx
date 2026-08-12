import { useState } from 'react'
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet'
import MobileShell from '@/components/MobileShell'
import BottomNav from '@/components/BottomNav'
import { reports, SEVERITY_COLORS } from '@/data/mockData'
import { SeverityBadge, StatusBadge } from '@/components/Badge'

interface Props {
  onNavigate: (screen: string) => void
}

// Real KL-area coordinates for each report
const reportCoords: Record<string, [number, number]> = {
  'RPT-001': [3.1585, 101.7123],
  'RPT-002': [3.1073, 101.6069],
  'RPT-003': [3.0756, 101.5706],
  'RPT-004': [3.0898, 101.6673],
  'RPT-005': [3.1621, 101.7041],
  'RPT-006': [3.1781, 101.6836],
}

export default function MapScreen({ onNavigate }: Props) {
  const [activeReport, setActiveReport] = useState<string | null>(null)

  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Top bar */}
        <div className="bg-[#0F172A] pt-12 px-4 pb-3 flex items-center gap-3">
          <span className="text-white font-bold text-base tracking-tight shrink-0">SafeJalan</span>
          <div className="flex-1 flex items-center gap-2 bg-white/10 rounded-xl px-3 py-1.5">
            <svg viewBox="0 0 24 24" className="w-3.5 h-3.5 fill-slate-300 shrink-0">
              <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
            </svg>
            <span className="text-slate-400 text-xs">Search location…</span>
          </div>
          <button className="relative w-8 h-8 bg-white/10 rounded-xl flex items-center justify-center shrink-0">
            <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-300">
              <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z" />
            </svg>
            <span className="absolute top-1 right-1 w-1.5 h-1.5 bg-red-500 rounded-full" />
          </button>
        </div>

        {/* Real Leaflet map — 2:1 ratio vs cards below */}
        <div className="relative" style={{ height: 430 }}>
          <MapContainer
            center={[3.1390, 101.6869]}
            zoom={12}
            style={{ height: '100%', width: '100%' }}
            zoomControl={true}
            attributionControl={false}
          >
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution="© OpenStreetMap contributors"
            />

            {reports.map((r) => {
              const pos = reportCoords[r.id]
              if (!pos) return null
              return (
                <CircleMarker
                  key={r.id}
                  center={pos}
                  radius={10}
                  fillColor={SEVERITY_COLORS[r.severity]}
                  color="white"
                  weight={2}
                  opacity={1}
                  fillOpacity={0.9}
                  eventHandlers={{
                    click: () => setActiveReport(r.id),
                  }}
                >
                  <Popup>
                    <div style={{ minWidth: 160 }}>
                      <p style={{ fontWeight: 700, fontSize: 13, marginBottom: 2 }}>{r.title}</p>
                      <p style={{ fontSize: 11, color: '#64748b', marginBottom: 4 }}>{r.location}</p>
                      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
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
                          {r.severity}
                        </span>
                        <span style={{ fontSize: 10, color: '#94a3b8' }}>{r.verifications} votes</span>
                      </div>
                      <button
                        onClick={() => onNavigate('user-report-detail')}
                        style={{
                          marginTop: 8,
                          width: '100%',
                          background: '#4361EE',
                          color: 'white',
                          border: 'none',
                          borderRadius: 8,
                          padding: '5px 0',
                          fontSize: 11,
                          fontWeight: 700,
                          cursor: 'pointer',
                        }}
                      >
                        View Report
                      </button>
                    </div>
                  </Popup>
                </CircleMarker>
              )
            })}
          </MapContainer>

          {/* Legend overlay */}
          <div className="absolute bottom-3 left-3 z-[1000] bg-white/90 rounded-xl p-2 space-y-1 shadow-sm">
            {['Critical', 'High', 'Medium', 'Low'].map((s) => (
              <div key={s} className="flex items-center gap-1.5">
                <div className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: SEVERITY_COLORS[s] }} />
                <span className="text-[10px] text-[#1E293B] font-medium">{s}</span>
              </div>
            ))}
          </div>

          {/* Attribution */}
          <div className="absolute bottom-1 right-1 z-[1000] bg-white/80 rounded px-1.5 py-0.5">
            <span className="text-[8px] text-slate-500">© OpenStreetMap</span>
          </div>
        </div>

        {/* FAB */}
        <div className="relative -mt-5 flex justify-center z-[999]">
          <button
            onClick={() => onNavigate('user-report-damage')}
            className="bg-[#4361EE] text-white px-5 py-2.5 rounded-2xl shadow-lg shadow-[#4361EE]/40 flex items-center gap-2 font-semibold text-sm hover:bg-[#3451d4] transition-colors active:scale-95"
          >
            <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white">
              <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" />
            </svg>
            Report Damage
          </button>
        </div>

        {/* Report cards */}
        <div className="flex-1 overflow-hidden flex flex-col bg-[#F8FAFC]">
          <div className="px-4 pt-4 pb-2 flex items-center justify-between">
            <h3 className="font-semibold text-[#1E293B] text-sm">Nearby Reports</h3>
            <span className="text-xs text-slate-500">{reports.length} issues</span>
          </div>
          <div className="flex gap-3 px-4 pb-3 overflow-x-auto no-scrollbar">
            {reports.map((r) => (
              <button
                key={r.id}
                onClick={() => onNavigate('user-report-detail')}
                className="shrink-0 w-52 bg-white rounded-2xl border border-[#E2E8F0] p-3 text-left shadow-sm hover:shadow-md transition-shadow active:scale-95"
              >
                <div className="flex items-center justify-between mb-2">
                  <SeverityBadge severity={r.severity} />
                  <StatusBadge status={r.status} />
                </div>
                <p className="font-semibold text-sm text-[#1E293B] leading-snug mb-1 line-clamp-1">{r.title}</p>
                <p className="text-xs text-slate-500 flex items-center gap-1 mb-2">
                  <svg viewBox="0 0 24 24" className="w-3 h-3 fill-slate-400 shrink-0">
                    <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" />
                  </svg>
                  {r.location}
                </p>
                <div className="flex items-center gap-1 text-xs text-slate-400">
                  <svg viewBox="0 0 24 24" className="w-3 h-3 fill-slate-400">
                    <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                  </svg>
                  {r.verifications} verifications
                </div>
              </button>
            ))}
          </div>
        </div>

        <BottomNav active="user-map" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
