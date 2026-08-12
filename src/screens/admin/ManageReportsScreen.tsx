import { useState } from 'react'
import AdminLayout from '../../components/AdminLayout'
import { mockReports, type Report, type Severity, type ReportStatus } from '../../data/mockData'
import SeverityBadge from '../../components/SeverityBadge'

interface Props {
  navigate: (screen: string) => void
  activeScreen: string
  onLogout: () => void
}

const STATUS_OPTIONS: ReportStatus[] = ['pending', 'active', 'resolved', 'rejected']
const SEV_OPTIONS: Severity[] = ['low', 'medium', 'high', 'critical']

const TIMELINE = [
  { time: '09:23', event: 'Report submitted by Ahmad Farid', type: 'submit' },
  { time: '10:05', event: '3 community verifications received', type: 'verify' },
  { time: '14:30', event: 'Severity upgraded to High by AI system', type: 'ai' },
  { time: '15:00', event: 'Assigned to maintenance crew #7', type: 'assign' },
]

export default function ManageReportsScreen({ navigate, activeScreen, onLogout }: Props) {
  const [search, setSearch] = useState('')
  const [sevFilter, setSevFilter] = useState<string>('all')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selected, setSelected] = useState<Report | null>(null)
  const [adminNote, setAdminNote] = useState('')

  const filtered = mockReports.filter((r) => {
    const matchSearch = r.title.toLowerCase().includes(search.toLowerCase()) ||
      r.location.toLowerCase().includes(search.toLowerCase()) ||
      r.id.toLowerCase().includes(search.toLowerCase())
    const matchSev = sevFilter === 'all' || r.severity === sevFilter
    const matchStatus = statusFilter === 'all' || r.status === statusFilter
    return matchSearch && matchSev && matchStatus
  })

  return (
    <AdminLayout navigate={navigate} activeScreen={activeScreen} onLogout={onLogout}>
      <div className="flex gap-5 h-full">
        {/* Main */}
        <div className="flex-1 min-w-0 space-y-4">
          <div>
            <div className="font-bold text-slate-800" style={{ fontSize: 22 }}>Manage Reports</div>
            <div style={{ color: '#64748b', fontSize: 13, marginTop: 2 }}>{mockReports.length} total reports</div>
          </div>

          {/* Filters */}
          <div className="flex flex-wrap items-center gap-3">
            <div className="relative">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" strokeWidth="2" className="absolute left-3 top-1/2 -translate-y-1/2">
                <circle cx="11" cy="11" r="8" /><path d="M21 21l-4.35-4.35" strokeLinecap="round" />
              </svg>
              <input
                type="text"
                placeholder="Search reports..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="outline-none text-slate-800"
                style={{
                  padding: '9px 12px 9px 34px',
                  border: '1.5px solid #E2E8F0',
                  borderRadius: 10,
                  fontSize: 13,
                  background: '#fff',
                  width: 200,
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = '#4361EE')}
                onBlur={(e) => (e.currentTarget.style.borderColor = '#E2E8F0')}
              />
            </div>
            <select
              value={sevFilter}
              onChange={(e) => setSevFilter(e.target.value)}
              className="outline-none font-medium"
              style={{
                padding: '9px 32px 9px 12px',
                border: '1.5px solid #E2E8F0',
                borderRadius: 10,
                fontSize: 13,
                background: '#fff',
                color: '#475569',
              }}
            >
              <option value="all">All Severity</option>
              {SEV_OPTIONS.map((s) => <option key={s} value={s} className="capitalize">{s.charAt(0).toUpperCase() + s.slice(1)}</option>)}
            </select>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="outline-none font-medium"
              style={{
                padding: '9px 32px 9px 12px',
                border: '1.5px solid #E2E8F0',
                borderRadius: 10,
                fontSize: 13,
                background: '#fff',
                color: '#475569',
              }}
            >
              <option value="all">All Status</option>
              {STATUS_OPTIONS.map((s) => <option key={s} value={s} className="capitalize">{s.charAt(0).toUpperCase() + s.slice(1)}</option>)}
            </select>
          </div>

          {/* Table */}
          <div
            className="rounded-2xl overflow-hidden"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <table className="w-full">
              <thead>
                <tr style={{ background: '#f8fafc', borderBottom: '1px solid #E2E8F0' }}>
                  {['', 'ID', 'Title', 'Category', 'Severity', 'Reporter', 'Date', 'Status', 'Actions'].map((h) => (
                    <th
                      key={h}
                      className="text-left font-semibold"
                      style={{ padding: '11px 12px', fontSize: 11, color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.05em' }}
                    >
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((r) => (
                  <tr
                    key={r.id}
                    className="cursor-pointer transition-colors"
                    style={{ borderTop: '1px solid #f1f5f9' }}
                    onClick={() => setSelected(r)}
                    onMouseEnter={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '#f8fafc')}
                    onMouseLeave={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '')}
                  >
                    <td style={{ padding: '10px 12px' }}>
                      <img src={r.imageUrl} alt="" className="rounded-lg object-cover" style={{ width: 44, height: 36 }} />
                    </td>
                    <td style={{ padding: '10px 12px', fontSize: 11, color: '#94a3b8', fontWeight: 600 }}>{r.id}</td>
                    <td style={{ padding: '10px 12px', fontSize: 13, color: '#1E293B', fontWeight: 500, maxWidth: 140 }}>
                      <div className="truncate">{r.title}</div>
                    </td>
                    <td style={{ padding: '10px 12px', fontSize: 12, color: '#475569' }}>{r.category}</td>
                    <td style={{ padding: '10px 12px' }}><SeverityBadge severity={r.severity} /></td>
                    <td style={{ padding: '10px 12px', fontSize: 12, color: '#475569' }}>{r.reporter}</td>
                    <td style={{ padding: '10px 12px', fontSize: 11, color: '#94a3b8' }}>{r.date.split(' ')[0]}</td>
                    <td style={{ padding: '10px 12px' }}>
                      <span
                        style={{
                          fontSize: 10,
                          fontWeight: 700,
                          padding: '3px 8px',
                          borderRadius: 20,
                          background: r.status === 'resolved' ? '#dcfce7' : r.status === 'active' ? '#dbeafe' : r.status === 'pending' ? '#fef3c7' : '#fee2e2',
                          color: r.status === 'resolved' ? '#15803d' : r.status === 'active' ? '#1d4ed8' : r.status === 'pending' ? '#92400e' : '#dc2626',
                          textTransform: 'capitalize',
                        }}
                      >
                        {r.status}
                      </span>
                    </td>
                    <td style={{ padding: '10px 12px' }}>
                      <div className="flex gap-1" onClick={(e) => e.stopPropagation()}>
                        {[
                          { icon: '👁', bg: '#eff6ff', color: '#4361EE' },
                          { icon: '✅', bg: '#dcfce7', color: '#15803d' },
                          { icon: '❌', bg: '#fee2e2', color: '#dc2626' },
                        ].map((a, i) => (
                          <button
                            key={i}
                            className="rounded-lg transition-opacity hover:opacity-80"
                            style={{ width: 28, height: 28, fontSize: 13, background: a.bg }}
                          >
                            {a.icon}
                          </button>
                        ))}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Detail panel */}
        {selected && (
          <div
            className="flex-shrink-0 rounded-2xl overflow-hidden flex flex-col"
            style={{ width: 320, background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 4px 16px rgba(0,0,0,0.08)', maxHeight: '80vh', overflowY: 'auto' }}
          >
            <div className="flex items-center justify-between px-4 py-3 flex-shrink-0" style={{ borderBottom: '1px solid #E2E8F0' }}>
              <div className="font-bold text-slate-800" style={{ fontSize: 14 }}>Report Detail</div>
              <button onClick={() => setSelected(null)}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" strokeWidth="2">
                  <path d="M18 6L6 18M6 6l12 12" strokeLinecap="round" />
                </svg>
              </button>
            </div>

            <img src={selected.imageUrl} alt={selected.title} className="w-full object-cover flex-shrink-0" style={{ height: 140 }} />

            <div className="px-4 py-3 space-y-3">
              <div>
                <SeverityBadge severity={selected.severity} size="md" />
                <div className="font-bold text-slate-800 mt-2" style={{ fontSize: 15 }}>{selected.title}</div>
                <div style={{ fontSize: 12, color: '#64748b', marginTop: 2 }}>{selected.location}</div>
              </div>

              {/* GPS mini map */}
              <div
                className="rounded-xl overflow-hidden relative"
                style={{ height: 80, background: '#e8f0e8' }}
              >
                <svg className="absolute inset-0 w-full h-full" viewBox="0 0 320 80" preserveAspectRatio="none">
                  <rect x="0" y="35" width="320" height="10" fill="#fff" opacity="0.7" />
                  <rect x="140" y="0" width="10" height="80" fill="#fff" opacity="0.7" />
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <div
                    className="rounded-full border-2 border-white shadow-lg"
                    style={{ width: 24, height: 24, background: '#EF4444', boxShadow: '0 0 12px rgba(239,68,68,0.6)' }}
                  />
                </div>
                <div className="absolute bottom-1.5 right-2" style={{ fontSize: 10, color: '#64748b', background: 'rgba(255,255,255,0.8)', borderRadius: 4, padding: '1px 4px' }}>
                  {selected.lat.toFixed(4)}°N {selected.lng.toFixed(4)}°E
                </div>
              </div>

              <div style={{ fontSize: 13, color: '#475569', lineHeight: 1.6 }}>{selected.description}</div>

              <div className="grid grid-cols-2 gap-2">
                {[
                  { label: 'Category', value: selected.category },
                  { label: 'Reporter', value: selected.reporter },
                  { label: 'Date', value: selected.date.split(' ')[0] },
                  { label: 'Verifications', value: String(selected.verifications) },
                ].map(({ label, value }) => (
                  <div key={label} className="rounded-lg p-2" style={{ background: '#f8fafc' }}>
                    <div style={{ fontSize: 10, color: '#94a3b8', fontWeight: 600, textTransform: 'uppercase' }}>{label}</div>
                    <div className="font-semibold text-slate-800" style={{ fontSize: 12, marginTop: 1 }}>{value}</div>
                  </div>
                ))}
              </div>

              {/* Timeline */}
              <div>
                <div className="font-semibold text-slate-800 mb-2" style={{ fontSize: 12 }}>Activity Timeline</div>
                <div className="space-y-2">
                  {TIMELINE.map((t, i) => (
                    <div key={i} className="flex gap-2.5 items-start">
                      <div
                        className="flex-shrink-0 rounded-full"
                        style={{ width: 6, height: 6, background: '#4361EE', marginTop: 5 }}
                      />
                      <div>
                        <div style={{ fontSize: 11, color: '#475569' }}>{t.event}</div>
                        <div style={{ fontSize: 10, color: '#94a3b8' }}>{t.time}</div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Admin notes */}
              <div>
                <label style={{ fontSize: 12, fontWeight: 600, color: '#475569' }}>Admin Notes</label>
                <textarea
                  value={adminNote}
                  onChange={(e) => setAdminNote(e.target.value)}
                  placeholder="Add internal notes..."
                  rows={2}
                  className="w-full outline-none resize-none text-slate-800 mt-1"
                  style={{
                    padding: '8px 10px',
                    border: '1.5px solid #E2E8F0',
                    borderRadius: 10,
                    fontSize: 12,
                    background: '#f8fafc',
                    lineHeight: 1.5,
                  }}
                />
              </div>

              {/* Actions */}
              <div className="grid grid-cols-2 gap-2">
                {[
                  { label: '✅ Approve', bg: '#dcfce7', color: '#15803d', border: '#bbf7d0' },
                  { label: '❌ Reject', bg: '#fee2e2', color: '#dc2626', border: '#fecaca' },
                  { label: '🔧 Assign', bg: '#eff6ff', color: '#4361EE', border: '#bfdbfe' },
                  { label: '✓ Resolved', bg: '#f0fdf4', color: '#15803d', border: '#bbf7d0' },
                ].map((a) => (
                  <button
                    key={a.label}
                    className="rounded-xl font-semibold transition-opacity hover:opacity-80"
                    style={{ padding: '8px', fontSize: 12, background: a.bg, color: a.color, border: `1.5px solid ${a.border}` }}
                  >
                    {a.label}
                  </button>
                ))}
              </div>
              <button
                className="w-full rounded-xl font-semibold text-white transition-opacity hover:opacity-90"
                style={{ padding: '9px', fontSize: 13, background: '#dc2626' }}
              >
                🗑 Delete Report
              </button>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  )
}
