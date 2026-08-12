import AdminLayout from '../../components/AdminLayout'
import { mockReports, monthlyReportData, categoryData } from '../../data/mockData'
import SeverityBadge from '../../components/SeverityBadge'
import {
  ResponsiveContainer, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  PieChart, Pie, Cell,
} from 'recharts'

interface Props {
  navigate: (screen: string) => void
  activeScreen: string
  onLogout: () => void
}

const STAT_CARDS = [
  { label: 'Total Users', value: '12,540', change: '+8.2%', up: true, icon: '👥', color: '#4361EE', bg: '#eff6ff' },
  { label: 'Total Reports', value: '2,840', change: '+12.5%', up: true, icon: '📋', color: '#8b5cf6', bg: '#f5f3ff' },
  { label: 'Active Reports', value: '142', change: '-3.1%', up: false, icon: '⚠️', color: '#F97316', bg: '#fff7ed' },
  { label: 'Resolved', value: '2,698', change: '+15.2%', up: true, icon: '✅', color: '#22C55E', bg: '#f0fdf4' },
  { label: 'Connectivity', value: '318', change: '+4.8%', up: true, icon: '📶', color: '#06b6d4', bg: '#ecfeff' },
  { label: 'Pending Review', value: '47', change: '-8.7%', up: false, icon: '🕒', color: '#FACC15', bg: '#fefce8' },
]

export default function AdminDashboardScreen({ navigate, activeScreen, onLogout }: Props) {
  return (
    <AdminLayout navigate={navigate} activeScreen={activeScreen} onLogout={onLogout}>
      <div className="space-y-6">
        {/* Page header */}
        <div>
          <div className="font-bold text-slate-800" style={{ fontSize: 22 }}>Dashboard Overview</div>
          <div style={{ color: '#64748b', fontSize: 13, marginTop: 2 }}>Welcome back, Admin. Here's what's happening today.</div>
        </div>

        {/* Stat cards */}
        <div className="grid gap-4" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
          {STAT_CARDS.map((s) => (
            <div
              key={s.label}
              className="rounded-2xl p-5 flex items-start justify-between"
              style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
            >
              <div>
                <div style={{ fontSize: 12, color: '#94a3b8', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em' }}>{s.label}</div>
                <div className="font-bold text-slate-800" style={{ fontSize: 26, marginTop: 4 }}>{s.value}</div>
                <div
                  className="inline-flex items-center gap-1 rounded-full mt-2"
                  style={{
                    fontSize: 11,
                    fontWeight: 700,
                    padding: '2px 8px',
                    background: s.up ? '#dcfce7' : '#fee2e2',
                    color: s.up ? '#15803d' : '#dc2626',
                  }}
                >
                  {s.up ? '↑' : '↓'} {s.change}
                </div>
              </div>
              <div
                className="rounded-xl flex items-center justify-center"
                style={{ width: 44, height: 44, background: s.bg, fontSize: 22 }}
              >
                {s.icon}
              </div>
            </div>
          ))}
        </div>

        {/* Charts row */}
        <div className="grid gap-4" style={{ gridTemplateColumns: '2fr 1fr' }}>
          {/* Line chart */}
          <div
            className="rounded-2xl p-5"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <div className="flex items-center justify-between mb-4">
              <div>
                <div className="font-bold text-slate-800" style={{ fontSize: 15 }}>Monthly Reports</div>
                <div style={{ fontSize: 12, color: '#94a3b8' }}>Last 7 months</div>
              </div>
              <div
                className="rounded-lg font-semibold"
                style={{ padding: '4px 12px', background: '#eff6ff', color: '#4361EE', fontSize: 12 }}
              >
                2024
              </div>
            </div>
            <ResponsiveContainer width="100%" height={200}>
              <LineChart data={monthlyReportData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <Tooltip
                  contentStyle={{ borderRadius: 12, border: '1px solid #E2E8F0', fontSize: 12 }}
                  cursor={{ stroke: '#4361EE', strokeWidth: 1, strokeDasharray: '4 4' }}
                />
                <Line
                  type="monotone"
                  dataKey="reports"
                  stroke="#4361EE"
                  strokeWidth={2.5}
                  dot={{ fill: '#4361EE', r: 4, strokeWidth: 2, stroke: '#fff' }}
                  activeDot={{ r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Pie chart */}
          <div
            className="rounded-2xl p-5"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <div className="font-bold text-slate-800 mb-1" style={{ fontSize: 15 }}>By Category</div>
            <div style={{ fontSize: 12, color: '#94a3b8', marginBottom: 8 }}>Report distribution</div>
            <ResponsiveContainer width="100%" height={160}>
              <PieChart>
                <Pie data={categoryData} cx="50%" cy="50%" innerRadius={40} outerRadius={70} paddingAngle={3} dataKey="value">
                  {categoryData.map((entry) => <Cell key={entry.name} fill={entry.color} />)}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 12, border: '1px solid #E2E8F0', fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
            <div className="space-y-1.5 mt-2">
              {categoryData.slice(0, 4).map((d) => (
                <div key={d.name} className="flex items-center justify-between">
                  <div className="flex items-center gap-1.5">
                    <div className="rounded-sm" style={{ width: 8, height: 8, background: d.color }} />
                    <span style={{ fontSize: 11, color: '#64748b' }}>{d.name}</span>
                  </div>
                  <span style={{ fontSize: 11, fontWeight: 600, color: '#1E293B' }}>{d.value}%</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Recent reports table */}
        <div
          className="rounded-2xl overflow-hidden"
          style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
        >
          <div className="flex items-center justify-between px-5 py-4" style={{ borderBottom: '1px solid #E2E8F0' }}>
            <div className="font-bold text-slate-800" style={{ fontSize: 15 }}>Recent Reports</div>
            <button
              onClick={() => navigate('reports')}
              style={{ fontSize: 12, color: '#4361EE', fontWeight: 600 }}
            >
              View All →
            </button>
          </div>
          <table className="w-full">
            <thead>
              <tr style={{ background: '#f8fafc' }}>
                {['ID', 'Title', 'Category', 'Severity', 'Location', 'Reporter', 'Status', 'Date'].map((h) => (
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
              {mockReports.map((r) => (
                <tr
                  key={r.id}
                  className="transition-colors"
                  style={{ borderTop: '1px solid #f1f5f9' }}
                  onMouseEnter={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '#f8fafc')}
                  onMouseLeave={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '')}
                >
                  <td style={{ padding: '12px 16px', fontSize: 12, color: '#94a3b8', fontWeight: 600 }}>{r.id}</td>
                  <td style={{ padding: '12px 16px', fontSize: 13, color: '#1E293B', fontWeight: 500, maxWidth: 160 }}>
                    <div className="truncate">{r.title}</div>
                  </td>
                  <td style={{ padding: '12px 16px', fontSize: 12, color: '#475569' }}>{r.category}</td>
                  <td style={{ padding: '12px 16px' }}><SeverityBadge severity={r.severity} /></td>
                  <td style={{ padding: '12px 16px', fontSize: 12, color: '#64748b', maxWidth: 140 }}>
                    <div className="truncate">{r.location}</div>
                  </td>
                  <td style={{ padding: '12px 16px', fontSize: 12, color: '#475569' }}>{r.reporter}</td>
                  <td style={{ padding: '12px 16px' }}>
                    <span
                      style={{
                        fontSize: 11,
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
                  <td style={{ padding: '12px 16px', fontSize: 12, color: '#94a3b8' }}>{r.date.split(' ')[0]}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  )
}
