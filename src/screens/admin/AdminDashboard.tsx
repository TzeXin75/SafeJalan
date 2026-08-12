import MobileShell from '@/components/MobileShell'
import AdminMobileNav from '@/components/AdminMobileNav'
import { reports, monthlyData, categoryData } from '@/data/mockData'
import { SeverityBadge, StatusBadge } from '@/components/Badge'
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'

interface Props {
  onNavigate: (screen: string) => void
}

const stats = [
  { label: 'Total Users', value: '1,284', icon: 'M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z', color: '#4361EE', bg: '#4361EE15' },
  { label: 'Total Reports', value: '263', icon: 'M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 9h-2V5h2v6zm0 4h-2v-2h2v2z', color: '#4361EE', bg: '#4361EE15' },
  { label: 'Active', value: '87', icon: 'M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z', color: '#F97316', bg: '#F9731615' },
  { label: 'Resolved', value: '148', icon: 'M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z', color: '#22C55E', bg: '#22C55E15' },
  { label: 'Connectivity', value: '28', icon: 'M1 9l2 2c4.97-4.97 13.03-4.97 18 0l2-2C16.93 2.93 7.08 2.93 1 9z', color: '#4361EE', bg: '#4361EE15' },
  { label: 'Pending', value: '28', icon: 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z', color: '#EF4444', bg: '#EF444415' },
]

const PIE_COLORS = ['#4361EE', '#F97316', '#22C55E', '#FACC15', '#EF4444']

export default function AdminDashboard({ onNavigate }: Props) {
  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-4 px-5 flex items-center justify-between">
          <div>
            <h1 className="text-white font-bold text-lg">Dashboard</h1>
            <p className="text-slate-400 text-xs">July 2026 overview</p>
          </div>
          <div className="flex items-center gap-2">
            <button className="relative w-8 h-8 bg-white/10 rounded-xl flex items-center justify-center">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-300">
                <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z" />
              </svg>
              <span className="absolute top-1 right-1 w-1.5 h-1.5 bg-red-500 rounded-full" />
            </button>
            <button
              className="flex items-center gap-2 bg-white/10 rounded-xl px-2.5 py-1.5 hover:bg-white/15 transition-colors active:scale-95"
              title="Admin Profile"
            >
              <div className="w-6 h-6 rounded-full bg-[#4361EE] flex items-center justify-center text-white text-[10px] font-bold">
                AD
              </div>
              <div className="text-left">
                <p className="text-white text-xs font-semibold leading-none">Admin</p>
                <p className="text-slate-400 text-[10px] leading-none mt-0.5">Super Admin</p>
              </div>
            </button>
            <button
              onClick={() => onNavigate('entry')}
              className="w-8 h-8 bg-red-500/20 rounded-xl flex items-center justify-center hover:bg-red-500/30 transition-colors"
              title="Sign Out"
            >
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-red-400">
                <path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z" />
              </svg>
            </button>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] px-4 py-4 space-y-4">
          {/* Stat grid */}
          <div className="grid grid-cols-3 gap-2.5">
            {stats.map((s) => (
              <div key={s.label} className="bg-white rounded-2xl border border-[#E2E8F0] p-3 shadow-sm">
                <div className="w-7 h-7 rounded-lg flex items-center justify-center mb-2" style={{ backgroundColor: s.bg }}>
                  <svg viewBox="0 0 24 24" className="w-4 h-4" style={{ fill: s.color }}>
                    <path d={s.icon} />
                  </svg>
                </div>
                <p className="font-bold text-[#1E293B] text-lg leading-none">{s.value}</p>
                <p className="text-slate-400 text-[10px] mt-0.5">{s.label}</p>
              </div>
            ))}
          </div>

          {/* Line chart */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
            <p className="font-semibold text-[#1E293B] text-sm mb-1">Monthly Reports</p>
            <p className="text-xs text-slate-400 mb-3">Submitted vs resolved</p>
            <ResponsiveContainer width="100%" height={160}>
              <LineChart data={monthlyData}>
                <XAxis dataKey="month" tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip contentStyle={{ borderRadius: 10, border: '1px solid #E2E8F0', fontSize: 11 }} />
                <Line type="monotone" dataKey="reports" stroke="#4361EE" strokeWidth={2} dot={{ r: 3, fill: '#4361EE' }} name="Submitted" />
                <Line type="monotone" dataKey="resolved" stroke="#22C55E" strokeWidth={2} dot={{ r: 3, fill: '#22C55E' }} name="Resolved" />
              </LineChart>
            </ResponsiveContainer>
            <div className="flex items-center gap-4 mt-2 justify-center">
              <div className="flex items-center gap-1.5"><div className="w-3 h-1.5 rounded-full bg-[#4361EE]" /><span className="text-xs text-slate-500">Submitted</span></div>
              <div className="flex items-center gap-1.5"><div className="w-3 h-1.5 rounded-full bg-[#22C55E]" /><span className="text-xs text-slate-500">Resolved</span></div>
            </div>
          </div>

          {/* Pie chart */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
            <p className="font-semibold text-[#1E293B] text-sm mb-3">Reports by Category</p>
            <div className="flex items-center gap-4">
              <ResponsiveContainer width={120} height={120}>
                <PieChart>
                  <Pie data={categoryData} cx="50%" cy="50%" innerRadius={35} outerRadius={55} dataKey="value" paddingAngle={3}>
                    {categoryData.map((_, i) => <Cell key={i} fill={PIE_COLORS[i]} />)}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
              <div className="flex-1 space-y-1.5">
                {categoryData.map((c, i) => (
                  <div key={c.name} className="flex items-center gap-2">
                    <div className="w-2 h-2 rounded-full shrink-0" style={{ backgroundColor: PIE_COLORS[i] }} />
                    <span className="text-xs text-slate-600 flex-1 truncate">{c.name}</span>
                    <span className="text-xs font-semibold text-[#1E293B]">{c.value}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Recent reports */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] shadow-sm overflow-hidden">
            <div className="px-4 py-3 border-b border-[#E2E8F0] flex items-center justify-between">
              <p className="font-semibold text-[#1E293B] text-sm">Recent Reports</p>
              <button onClick={() => onNavigate('admin-reports')} className="text-[#4361EE] text-xs font-medium">
                View all
              </button>
            </div>
            <div className="divide-y divide-[#E2E8F0]">
              {reports.slice(0, 4).map((r) => (
                <button
                  key={r.id}
                  onClick={() => onNavigate('admin-reports')}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-[#F8FAFC] text-left transition-colors"
                >
                  <img src={r.imageUrl} alt={r.title} className="w-10 h-10 rounded-xl object-cover bg-slate-100 shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-[#1E293B] truncate">{r.title}</p>
                    <p className="text-xs text-slate-400 truncate">{r.location}</p>
                  </div>
                  <div className="flex flex-col items-end gap-1 shrink-0">
                    <SeverityBadge severity={r.severity} />
                    <StatusBadge status={r.status} />
                  </div>
                </button>
              ))}
            </div>
          </div>


        </div>

        <AdminMobileNav active="admin-dashboard" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
