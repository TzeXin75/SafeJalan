import MobileShell from '@/components/MobileShell'
import AdminMobileNav from '@/components/AdminMobileNav'
import { monthlyData, categoryData, severityData, leaderboard } from '@/data/mockData'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend, LineChart, Line,
} from 'recharts'

interface Props {
  onNavigate: (screen: string) => void
}

const PIE_COLORS = ['#4361EE', '#F97316', '#22C55E', '#FACC15', '#EF4444']

export default function Statistics({ onNavigate }: Props) {
  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-4 px-5">
          <h1 className="text-white font-bold text-lg">Statistics</h1>
          <p className="text-slate-400 text-xs mt-0.5">Analytics overview · July 2026</p>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] px-4 py-4 space-y-4">
          {/* KPI cards */}
          <div className="grid grid-cols-2 gap-2.5">
            {[
              { label: 'Completion Rate', value: '72%', icon: '✅', color: '#22C55E' },
              { label: 'Avg Resolution', value: '3.4d', icon: '⏱', color: '#4361EE' },
              { label: 'Active Users', value: '318', icon: '👥', color: '#4361EE' },
              { label: 'Verifications', value: '1,240', icon: '🎯', color: '#F97316' },
            ].map((k) => (
              <div key={k.label} className="bg-white rounded-2xl border border-[#E2E8F0] p-3.5 shadow-sm">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xl">{k.icon}</span>
                </div>
                <p className="text-2xl font-bold" style={{ color: k.color }}>{k.value}</p>
                <p className="text-xs text-slate-400 mt-0.5">{k.label}</p>
              </div>
            ))}
          </div>

          {/* Bar chart */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
            <p className="font-semibold text-[#1E293B] text-sm mb-0.5">Reports by Month</p>
            <p className="text-xs text-slate-400 mb-3">Submitted vs resolved</p>
            <ResponsiveContainer width="100%" height={160}>
              <BarChart data={monthlyData} barSize={18} barGap={3}>
                <XAxis dataKey="month" tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip contentStyle={{ borderRadius: 10, border: '1px solid #E2E8F0', fontSize: 11 }} />
                <Bar dataKey="reports" fill="#4361EE" radius={[4, 4, 0, 0]} name="Submitted" />
                <Bar dataKey="resolved" fill="#22C55E" radius={[4, 4, 0, 0]} name="Resolved" />
              </BarChart>
            </ResponsiveContainer>
            <div className="flex justify-center gap-4 mt-1">
              <div className="flex items-center gap-1.5"><div className="w-3 h-1.5 rounded-full bg-[#4361EE]" /><span className="text-xs text-slate-500">Submitted</span></div>
              <div className="flex items-center gap-1.5"><div className="w-3 h-1.5 rounded-full bg-[#22C55E]" /><span className="text-xs text-slate-500">Resolved</span></div>
            </div>
          </div>

          {/* Line trend */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
            <p className="font-semibold text-[#1E293B] text-sm mb-0.5">Report Trend</p>
            <p className="text-xs text-slate-400 mb-3">Growth over time</p>
            <ResponsiveContainer width="100%" height={140}>
              <LineChart data={monthlyData}>
                <XAxis dataKey="month" tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip contentStyle={{ borderRadius: 10, border: '1px solid #E2E8F0', fontSize: 11 }} />
                <Line type="monotone" dataKey="reports" stroke="#4361EE" strokeWidth={2.5} dot={{ r: 3, fill: '#4361EE' }} name="Submitted" />
                <Line type="monotone" dataKey="resolved" stroke="#22C55E" strokeWidth={2.5} dot={{ r: 3, fill: '#22C55E' }} name="Resolved" />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Category pie */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
            <p className="font-semibold text-[#1E293B] text-sm mb-3">Report Categories</p>
            <div className="flex items-center gap-3">
              <ResponsiveContainer width={110} height={110}>
                <PieChart>
                  <Pie data={categoryData} cx="50%" cy="50%" outerRadius={50} dataKey="value" paddingAngle={2}>
                    {categoryData.map((_, i) => <Cell key={i} fill={PIE_COLORS[i]} />)}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
              <div className="flex-1 space-y-1.5">
                {categoryData.map((c, i) => (
                  <div key={c.name} className="flex items-center gap-2">
                    <div className="w-2 h-2 rounded-full shrink-0" style={{ backgroundColor: PIE_COLORS[i] }} />
                    <span className="text-xs text-slate-600 flex-1 truncate">{c.name}</span>
                    <span className="text-xs font-bold text-[#1E293B]">{c.value}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Severity donut */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
            <p className="font-semibold text-[#1E293B] text-sm mb-3">Severity Distribution</p>
            <div className="flex items-center gap-3">
              <ResponsiveContainer width={110} height={110}>
                <PieChart>
                  <Pie data={severityData} cx="50%" cy="50%" innerRadius={32} outerRadius={50} dataKey="value" paddingAngle={3}>
                    {severityData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
              <div className="flex-1 space-y-1.5">
                {severityData.map((s) => (
                  <div key={s.name} className="flex items-center gap-2">
                    <div className="w-2 h-2 rounded-full shrink-0" style={{ backgroundColor: s.color }} />
                    <span className="text-xs text-slate-600 flex-1">{s.name}</span>
                    <span className="text-xs font-bold text-[#1E293B]">{s.value}%</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Top contributors */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
            <p className="font-semibold text-[#1E293B] text-sm mb-3">Top Contributors</p>
            <div className="space-y-3">
              {leaderboard.slice(0, 5).map((u, i) => (
                <div key={i} className="flex items-center gap-2.5">
                  <span className="text-xs font-bold text-slate-400 w-4 shrink-0">{i + 1}</span>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-[#1E293B] truncate">{u.name}</p>
                    <div className="mt-1 bg-[#F1F5F9] rounded-full h-1.5">
                      <div className="h-1.5 rounded-full bg-[#4361EE]" style={{ width: `${(u.points / leaderboard[0].points) * 100}%` }} />
                    </div>
                  </div>
                  <span className="text-xs font-bold text-[#4361EE] shrink-0">{u.points} pts</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <AdminMobileNav active="admin-statistics" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
