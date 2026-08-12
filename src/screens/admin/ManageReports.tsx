import { useState } from 'react'
import MobileShell from '@/components/MobileShell'
import AdminMobileNav from '@/components/AdminMobileNav'
import { reports, type Report } from '@/data/mockData'
import { SeverityBadge, StatusBadge } from '@/components/Badge'

interface Props {
  onNavigate: (screen: string) => void
}

function ReportDrawer({ report: r, onClose }: { report: Report; onClose: () => void }) {
  const [note, setNote] = useState('')

  return (
    <div className="absolute inset-0 bg-white z-20 flex flex-col overflow-y-auto no-scrollbar">
      {/* Image */}
      <div className="relative shrink-0">
        <img src={r.imageUrl} alt={r.title} className="w-full h-44 object-cover bg-slate-100" />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
        <button onClick={onClose} className="absolute top-12 left-4 w-8 h-8 bg-black/40 rounded-xl flex items-center justify-center">
          <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white">
            <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
          </svg>
        </button>
        <div className="absolute bottom-3 left-4 right-4">
          <p className="text-white font-bold text-base leading-snug line-clamp-2">{r.title}</p>
        </div>
      </div>

      <div className="flex-1 bg-[#F8FAFC] px-4 py-4 space-y-4">
        {/* Badges */}
        <div className="flex items-center gap-2 flex-wrap">
          <SeverityBadge severity={r.severity} />
          <StatusBadge status={r.status} />
          <span className="text-xs text-slate-400 ml-auto font-mono">{r.id}</span>
        </div>

        {/* Info */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm space-y-2.5">
          {[
            ['Category', r.category],
            ['Location', r.location],
            ['Reporter', r.reporter],
            ['Date Submitted', r.date],
            ['Verifications', String(r.verifications)],
            ['AI Prediction', r.severity + ' confidence 94%'],
            ['Duplicate', 'No duplicate found'],
          ].map(([k, v]) => (
            <div key={k} className="flex items-start justify-between gap-3 text-sm">
              <span className="text-slate-400 shrink-0">{k}</span>
              <span className="font-semibold text-[#1E293B] text-right">{v}</span>
            </div>
          ))}
        </div>

        {/* Description */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
          <p className="text-xs font-semibold text-slate-500 mb-1.5">DESCRIPTION</p>
          <p className="text-sm text-slate-600 leading-relaxed">{r.description}</p>
        </div>

        {/* Verification timeline */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
          <p className="text-xs font-semibold text-slate-500 mb-3">COMMUNITY VERIFICATION</p>
          <div className="space-y-2">
            {[
              { user: 'Ahmad Razif', vote: 'Still Exists', time: '2h ago', color: '#F97316' },
              { user: 'Nurul Hana', vote: 'Still Exists', time: '4h ago', color: '#F97316' },
              { user: 'Tan Wei Ming', vote: 'Resolved', time: '6h ago', color: '#22C55E' },
            ].map((v, i) => (
              <div key={i} className="flex items-center gap-2.5 text-sm">
                <div className="w-1.5 h-1.5 rounded-full shrink-0" style={{ backgroundColor: v.color }} />
                <span className="font-medium text-[#1E293B]">{v.user}</span>
                <span className="text-slate-400">·</span>
                <span className="text-slate-500">{v.vote}</span>
                <span className="text-slate-300 ml-auto text-xs">{v.time}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Admin notes */}
        <div>
          <p className="text-xs font-semibold text-slate-500 mb-1.5">ADMIN NOTES</p>
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            rows={3}
            placeholder="Add internal notes for this report…"
            className="w-full border border-[#E2E8F0] rounded-xl bg-white px-3 py-2.5 text-sm text-[#1E293B] placeholder-slate-400 outline-none focus:border-[#4361EE] resize-none transition-colors"
          />
        </div>

        {/* Action buttons */}
        <div className="grid grid-cols-2 gap-2">
          <button className="py-3 bg-green-50 text-green-700 font-semibold rounded-xl text-sm hover:bg-green-100 transition-colors">Approve</button>
          <button className="py-3 bg-red-50 text-red-600 font-semibold rounded-xl text-sm hover:bg-red-100 transition-colors">Reject</button>
          <button className="py-3 bg-blue-50 text-[#4361EE] font-semibold rounded-xl text-sm hover:bg-blue-100 transition-colors">Edit Category</button>
          <button className="py-3 bg-purple-50 text-purple-600 font-semibold rounded-xl text-sm hover:bg-purple-100 transition-colors">Change Severity</button>
          <button className="py-3 col-span-2 bg-[#22C55E] text-white font-semibold rounded-xl text-sm hover:bg-green-600 transition-colors">Mark as Resolved</button>
          <button className="py-3 col-span-2 bg-[#EF4444]/10 text-[#EF4444] font-semibold rounded-xl text-sm hover:bg-[#EF4444]/20 transition-colors">Delete Report</button>
        </div>
      </div>
    </div>
  )
}

export default function ManageReports({ onNavigate }: Props) {
  const [search, setSearch] = useState('')
  const [sevFilter, setSevFilter] = useState('All')
  const [statusFilter, setStatusFilter] = useState('All')
  const [selected, setSelected] = useState<Report | null>(null)

  const filtered = reports.filter((r) => {
    const matchSearch = r.title.toLowerCase().includes(search.toLowerCase()) || r.location.toLowerCase().includes(search.toLowerCase())
    const matchSev = sevFilter === 'All' || r.severity === sevFilter
    const matchStatus = statusFilter === 'All' || r.status === statusFilter
    return matchSearch && matchSev && matchStatus
  })

  return (
    <MobileShell>
      <div className="flex flex-col h-full relative">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-4 px-5">
          <h1 className="text-white font-bold text-lg">Manage Reports</h1>
          <p className="text-slate-400 text-xs mt-0.5">{filtered.length} of {reports.length} reports</p>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] px-4 py-4 space-y-3">
          {/* Search */}
          <div className="flex items-center gap-2 border border-[#E2E8F0] rounded-xl bg-white px-3 focus-within:border-[#4361EE] transition-colors">
            <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
              <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
            </svg>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by title or location…"
              className="flex-1 py-2.5 text-sm bg-transparent outline-none text-[#1E293B] placeholder-slate-400"
            />
          </div>

          {/* Filters */}
          <div className="flex gap-2">
            <select value={sevFilter} onChange={(e) => setSevFilter(e.target.value)} className="flex-1 border border-[#E2E8F0] rounded-xl bg-white px-3 py-2 text-sm text-slate-600 outline-none">
              {['All', 'Critical', 'High', 'Medium', 'Low'].map((o) => <option key={o}>{o}</option>)}
            </select>
            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="flex-1 border border-[#E2E8F0] rounded-xl bg-white px-3 py-2 text-sm text-slate-600 outline-none">
              {['All', 'Active', 'Pending', 'Resolved', 'Rejected'].map((o) => <option key={o}>{o}</option>)}
            </select>
          </div>

          {/* Report cards */}
          <div className="space-y-2.5">
            {filtered.map((r) => (
              <div key={r.id} className="bg-white rounded-2xl border border-[#E2E8F0] shadow-sm overflow-hidden">
                <div className="flex gap-3 p-3">
                  <img src={r.imageUrl} alt={r.title} className="w-14 h-14 rounded-xl object-cover bg-slate-100 shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-[#1E293B] line-clamp-1">{r.title}</p>
                    <p className="text-xs text-slate-400 truncate mt-0.5">{r.location}</p>
                    <div className="flex items-center gap-1.5 mt-1.5 flex-wrap">
                      <SeverityBadge severity={r.severity} />
                      <StatusBadge status={r.status} />
                    </div>
                  </div>
                  <div className="shrink-0 text-right">
                    <p className="text-xs text-slate-400">{r.date}</p>
                    <p className="text-xs font-semibold text-[#4361EE] mt-1">{r.verifications} votes</p>
                  </div>
                </div>
                <div className="flex border-t border-[#E2E8F0]">
                  <button onClick={() => setSelected(r)} className="flex-1 py-2 text-xs font-semibold text-[#4361EE] hover:bg-blue-50 transition-colors">View</button>
                  <div className="w-px bg-[#E2E8F0]" />
                  <button className="flex-1 py-2 text-xs font-semibold text-[#22C55E] hover:bg-green-50 transition-colors">Approve</button>
                  <div className="w-px bg-[#E2E8F0]" />
                  <button className="flex-1 py-2 text-xs font-semibold text-[#EF4444] hover:bg-red-50 transition-colors">Reject</button>
                  <div className="w-px bg-[#E2E8F0]" />
                  <button className="flex-1 py-2 text-xs font-semibold text-slate-400 hover:bg-slate-50 transition-colors">Delete</button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <AdminMobileNav active="admin-reports" onNavigate={(s) => onNavigate(s)} />

        {selected && <ReportDrawer report={selected} onClose={() => setSelected(null)} />}
      </div>
    </MobileShell>
  )
}
