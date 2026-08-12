import AdminLayout from '../../components/AdminLayout'
import { monthlyReportData, categoryData, severityData, leaderboardUsers } from '../../data/mockData'
import {
  ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  PieChart, Pie, Cell, AreaChart, Area, Legend,
} from 'recharts'

interface Props {
  navigate: (screen: string) => void
  activeScreen: string
  onLogout: () => void
}

const trendData = [
  { week: 'W1', reports: 22, resolved: 18 },
  { week: 'W2', reports: 28, resolved: 24 },
  { week: 'W3', reports: 31, resolved: 27 },
  { week: 'W4', reports: 25, resolved: 20 },
  { week: 'W5', reports: 38, resolved: 32 },
  { week: 'W6', reports: 42, resolved: 35 },
  { week: 'W7', reports: 35, resolved: 30 },
  { week: 'W8', reports: 48, resolved: 41 },
]

const CUSTOM_TOOLTIP_STYLE = { borderRadius: 12, border: '1px solid #E2E8F0', fontSize: 12 }

export default function StatisticsScreen({ navigate, activeScreen, onLogout }: Props) {
  return (
    <AdminLayout navigate={navigate} activeScreen={activeScreen} onLogout={onLogout}>
      <div className="space-y-5">
        <div>
          <div className="font-bold text-slate-800" style={{ fontSize: 22 }}>Statistics & Analytics</div>
          <div style={{ color: '#64748b', fontSize: 13, marginTop: 2 }}>Comprehensive road safety data insights</div>
        </div>

        {/* KPI row */}
        <div className="grid gap-4" style={{ gridTemplateColumns: 'repeat(4, 1fr)' }}>
          {[
            { label: 'Report Completion Rate', value: '94.8%', sub: '+2.1% from last month', icon: '📈', color: '#22C55E' },
            { label: 'Avg Resolution Time', value: '3.2 days', sub: '-0.4 days improved', icon: '⏱', color: '#4361EE' },
            { label: 'Active Users (30d)', value: '8,421', sub: '+12.5% growth', icon: '👥', color: '#8b5cf6' },
            { label: 'Community Verifications', value: '31,205', sub: '+28% this month', icon: '✅', color: '#F97316' },
          ].map((k) => (
            <div
              key={k.label}
              className="rounded-2xl p-4"
              style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
            >
              <div className="text-2xl mb-2">{k.icon}</div>
              <div className="font-bold text-slate-800" style={{ fontSize: 22 }}>{k.value}</div>
              <div style={{ fontSize: 12, color: '#94a3b8', marginTop: 2 }}>{k.label}</div>
              <div style={{ fontSize: 11, color: k.color, fontWeight: 600, marginTop: 4 }}>{k.sub}</div>
            </div>
          ))}
        </div>

        {/* Charts row 1 */}
        <div className="grid gap-4" style={{ gridTemplateColumns: '1.5fr 1fr' }}>
          {/* Bar chart */}
          <div
            className="rounded-2xl p-5"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <div className="font-bold text-slate-800 mb-1" style={{ fontSize: 15 }}>Reports by Month</div>
            <div style={{ fontSize: 12, color: '#94a3b8', marginBottom: 16 }}>2024 annual overview</div>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={monthlyReportData} margin={{ top: 0, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
                <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={CUSTOM_TOOLTIP_STYLE} cursor={{ fill: '#f1f5f9', radius: 6 }} />
                <Bar dataKey="reports" fill="#4361EE" radius={[6, 6, 0, 0]} maxBarSize={44} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Severity donut */}
          <div
            className="rounded-2xl p-5"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <div className="font-bold text-slate-800 mb-1" style={{ fontSize: 15 }}>Severity Distribution</div>
            <div style={{ fontSize: 12, color: '#94a3b8', marginBottom: 8 }}>All time breakdown</div>
            <ResponsiveContainer width="100%" height={160}>
              <PieChart>
                <Pie data={severityData} cx="50%" cy="50%" innerRadius={45} outerRadius={70} paddingAngle={4} dataKey="value">
                  {severityData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 12, border: '1px solid #E2E8F0', fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
            <div className="grid grid-cols-2 gap-y-1.5 mt-1">
              {severityData.map((d) => (
                <div key={d.name} className="flex items-center gap-1.5">
                  <div className="rounded-sm" style={{ width: 8, height: 8, background: d.color }} />
                  <span style={{ fontSize: 11, color: '#64748b' }}>{d.name} {d.value}%</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Charts row 2 */}
        <div className="grid gap-4" style={{ gridTemplateColumns: '1.5fr 1fr' }}>
          {/* Area chart */}
          <div
            className="rounded-2xl p-5"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <div className="font-bold text-slate-800 mb-1" style={{ fontSize: 15 }}>Weekly Trend</div>
            <div style={{ fontSize: 12, color: '#94a3b8', marginBottom: 16 }}>Reports submitted vs resolved</div>
            <ResponsiveContainer width="100%" height={200}>
              <AreaChart data={trendData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorReports" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#4361EE" stopOpacity={0.2} />
                    <stop offset="95%" stopColor="#4361EE" stopOpacity={0} />
                  </linearGradient>
                  <linearGradient id="colorResolved" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#22C55E" stopOpacity={0.2} />
                    <stop offset="95%" stopColor="#22C55E" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="week" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={CUSTOM_TOOLTIP_STYLE} />
                <Legend iconSize={8} iconType="circle" wrapperStyle={{ fontSize: 12 }} />
                <Area type="monotone" dataKey="reports" stroke="#4361EE" strokeWidth={2} fill="url(#colorReports)" name="Submitted" />
                <Area type="monotone" dataKey="resolved" stroke="#22C55E" strokeWidth={2} fill="url(#colorResolved)" name="Resolved" />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          {/* Category pie */}
          <div
            className="rounded-2xl p-5"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <div className="font-bold text-slate-800 mb-1" style={{ fontSize: 15 }}>By Category</div>
            <div style={{ fontSize: 12, color: '#94a3b8', marginBottom: 8 }}>Report type distribution</div>
            <ResponsiveContainer width="100%" height={160}>
              <PieChart>
                <Pie data={categoryData} cx="50%" cy="50%" outerRadius={70} paddingAngle={3} dataKey="value">
                  {categoryData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 12, border: '1px solid #E2E8F0', fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
            <div className="space-y-1 mt-1">
              {categoryData.map((d) => (
                <div key={d.name} className="flex items-center justify-between">
                  <div className="flex items-center gap-1.5">
                    <div className="rounded-sm" style={{ width: 8, height: 8, background: d.color }} />
                    <span style={{ fontSize: 11, color: '#64748b' }}>{d.name}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div
                      className="rounded-full"
                      style={{ height: 4, background: d.color, width: d.value * 1.4, opacity: 0.7 }}
                    />
                    <span style={{ fontSize: 11, fontWeight: 600, color: '#1E293B', minWidth: 24 }}>{d.value}%</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Leaderboard table */}
        <div
          className="rounded-2xl overflow-hidden"
          style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
        >
          <div className="px-5 py-4" style={{ borderBottom: '1px solid #E2E8F0' }}>
            <div className="font-bold text-slate-800" style={{ fontSize: 15 }}>Top Contributors</div>
            <div style={{ fontSize: 12, color: '#94a3b8', marginTop: 1 }}>January 2024 leaderboard</div>
          </div>
          <table className="w-full">
            <thead>
              <tr style={{ background: '#f8fafc', borderBottom: '1px solid #E2E8F0' }}>
                {['Rank', 'Contributor', 'Reports', 'Points', 'Badges', 'Progress'].map((h) => (
                  <th
                    key={h}
                    className="text-left font-semibold"
                    style={{ padding: '10px 16px', fontSize: 11, color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.05em' }}
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {leaderboardUsers.map((u) => (
                <tr
                  key={u.rank}
                  className="transition-colors"
                  style={{ borderTop: '1px solid #f1f5f9' }}
                  onMouseEnter={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '#f8fafc')}
                  onMouseLeave={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '')}
                >
                  <td style={{ padding: '12px 16px' }}>
                    {u.rank <= 3 ? (
                      <span style={{ fontSize: 20 }}>{['🥇', '🥈', '🥉'][u.rank - 1]}</span>
                    ) : (
                      <span className="font-bold" style={{ fontSize: 14, color: '#94a3b8' }}>#{u.rank}</span>
                    )}
                  </td>
                  <td style={{ padding: '12px 16px' }}>
                    <div className="flex items-center gap-2.5">
                      <div
                        className="rounded-full flex items-center justify-center font-bold text-white"
                        style={{ width: 32, height: 32, background: '#4361EE', fontSize: 11, flexShrink: 0 }}
                      >
                        {u.avatar}
                      </div>
                      <span className="font-semibold text-slate-800" style={{ fontSize: 13 }}>{u.name}</span>
                    </div>
                  </td>
                  <td style={{ padding: '12px 16px', fontSize: 13, fontWeight: 600, color: '#1E293B' }}>{u.reports}</td>
                  <td style={{ padding: '12px 16px' }}>
                    <span className="font-bold" style={{ fontSize: 14, color: '#4361EE' }}>{u.points.toLocaleString()}</span>
                  </td>
                  <td style={{ padding: '12px 16px', fontSize: 13, color: '#64748b' }}>{u.badges}</td>
                  <td style={{ padding: '12px 16px', width: 160 }}>
                    <div className="flex items-center gap-2">
                      <div className="flex-1 rounded-full overflow-hidden" style={{ height: 6, background: '#f1f5f9' }}>
                        <div
                          className="h-full rounded-full"
                          style={{ width: `${(u.points / 1250) * 100}%`, background: u.rank === 1 ? '#F59E0B' : '#4361EE' }}
                        />
                      </div>
                      <span style={{ fontSize: 11, color: '#94a3b8', minWidth: 30 }}>{Math.round((u.points / 1250) * 100)}%</span>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  )
}
