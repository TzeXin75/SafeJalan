import { useState } from 'react'
import AdminLayout from '../../components/AdminLayout'
import { mockUsers, mockReports, type User } from '../../data/mockData'

interface Props {
  navigate: (screen: string) => void
  activeScreen: string
  onLogout: () => void
}

export default function ManageUsersScreen({ navigate, activeScreen, onLogout }: Props) {
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState<'all' | 'active' | 'suspended'>('all')
  const [selectedUser, setSelectedUser] = useState<User | null>(null)

  const filtered = mockUsers.filter((u) => {
    const matchSearch = u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase())
    const matchFilter = filter === 'all' || u.status === filter
    return matchSearch && matchFilter
  })

  return (
    <AdminLayout navigate={navigate} activeScreen={activeScreen} onLogout={onLogout}>
      <div className="flex gap-5 h-full">
        {/* Main table */}
        <div className="flex-1 min-w-0 space-y-4">
          <div>
            <div className="font-bold text-slate-800" style={{ fontSize: 22 }}>Manage Users</div>
            <div style={{ color: '#64748b', fontSize: 13, marginTop: 2 }}>
              {mockUsers.length} registered users
            </div>
          </div>

          {/* Filters */}
          <div className="flex items-center gap-3">
            <div className="relative flex-1 max-w-xs">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" strokeWidth="2" className="absolute left-3 top-1/2 -translate-y-1/2">
                <circle cx="11" cy="11" r="8" /><path d="M21 21l-4.35-4.35" strokeLinecap="round" />
              </svg>
              <input
                type="text"
                placeholder="Search users..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full outline-none text-slate-800"
                style={{
                  padding: '9px 12px 9px 34px',
                  border: '1.5px solid #E2E8F0',
                  borderRadius: 10,
                  fontSize: 13,
                  background: '#fff',
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = '#4361EE')}
                onBlur={(e) => (e.currentTarget.style.borderColor = '#E2E8F0')}
              />
            </div>
            {(['all', 'active', 'suspended'] as const).map((f) => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                className="rounded-lg capitalize font-semibold transition-colors"
                style={{
                  padding: '8px 16px',
                  fontSize: 13,
                  background: filter === f ? '#4361EE' : '#fff',
                  color: filter === f ? '#fff' : '#64748b',
                  border: `1.5px solid ${filter === f ? '#4361EE' : '#E2E8F0'}`,
                }}
              >
                {f}
              </button>
            ))}
          </div>

          {/* Table */}
          <div
            className="rounded-2xl overflow-hidden"
            style={{ background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
          >
            <table className="w-full">
              <thead>
                <tr style={{ background: '#f8fafc', borderBottom: '1px solid #E2E8F0' }}>
                  {['User', 'Email', 'Reports', 'Points', 'Status', 'Joined', 'Actions'].map((h) => (
                    <th
                      key={h}
                      className="text-left font-semibold"
                      style={{ padding: '11px 16px', fontSize: 11, color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.05em' }}
                    >
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((user) => (
                  <tr
                    key={user.id}
                    className="cursor-pointer transition-colors"
                    style={{ borderTop: '1px solid #f1f5f9' }}
                    onClick={() => setSelectedUser(user)}
                    onMouseEnter={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '#f8fafc')}
                    onMouseLeave={(e) => ((e.currentTarget as HTMLTableRowElement).style.background = '')}
                  >
                    <td style={{ padding: '12px 16px' }}>
                      <div className="flex items-center gap-2.5">
                        <div
                          className="rounded-full flex items-center justify-center font-bold text-white flex-shrink-0"
                          style={{ width: 34, height: 34, background: '#4361EE', fontSize: 12 }}
                        >
                          {user.avatar}
                        </div>
                        <span className="font-semibold text-slate-800" style={{ fontSize: 13 }}>{user.name}</span>
                      </div>
                    </td>
                    <td style={{ padding: '12px 16px', fontSize: 13, color: '#64748b' }}>{user.email}</td>
                    <td style={{ padding: '12px 16px', fontSize: 13, fontWeight: 600, color: '#1E293B' }}>{user.reports}</td>
                    <td style={{ padding: '12px 16px' }}>
                      <span className="font-bold" style={{ fontSize: 13, color: '#4361EE' }}>{user.points.toLocaleString()}</span>
                    </td>
                    <td style={{ padding: '12px 16px' }}>
                      <span
                        style={{
                          fontSize: 11,
                          fontWeight: 700,
                          padding: '3px 10px',
                          borderRadius: 20,
                          background: user.status === 'active' ? '#dcfce7' : '#fee2e2',
                          color: user.status === 'active' ? '#15803d' : '#dc2626',
                          textTransform: 'capitalize',
                        }}
                      >
                        {user.status}
                      </span>
                    </td>
                    <td style={{ padding: '12px 16px', fontSize: 12, color: '#94a3b8' }}>{user.joinDate}</td>
                    <td style={{ padding: '12px 16px' }}>
                      <div className="flex items-center gap-1.5" onClick={(e) => e.stopPropagation()}>
                        {[
                          { label: 'View', color: '#4361EE', bg: '#eff6ff' },
                          { label: user.status === 'active' ? 'Suspend' : 'Activate', color: user.status === 'active' ? '#ea580c' : '#22C55E', bg: user.status === 'active' ? '#ffedd5' : '#dcfce7' },
                          { label: 'Delete', color: '#dc2626', bg: '#fee2e2' },
                        ].map((btn) => (
                          <button
                            key={btn.label}
                            onClick={() => setSelectedUser(user)}
                            className="rounded-lg font-semibold transition-colors"
                            style={{ padding: '4px 8px', fontSize: 11, background: btn.bg, color: btn.color }}
                          >
                            {btn.label}
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

        {/* Side panel */}
        {selectedUser && (
          <div
            className="flex-shrink-0 flex flex-col rounded-2xl overflow-hidden"
            style={{ width: 300, background: '#fff', border: '1px solid #E2E8F0', boxShadow: '0 4px 16px rgba(0,0,0,0.08)', height: 'fit-content' }}
          >
            {/* Close */}
            <div className="flex items-center justify-between px-4 py-3" style={{ borderBottom: '1px solid #E2E8F0' }}>
              <div className="font-bold text-slate-800" style={{ fontSize: 14 }}>User Profile</div>
              <button onClick={() => setSelectedUser(null)}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" strokeWidth="2">
                  <path d="M18 6L6 18M6 6l12 12" strokeLinecap="round" />
                </svg>
              </button>
            </div>

            {/* Profile */}
            <div className="flex flex-col items-center py-5 px-4" style={{ background: 'linear-gradient(180deg, #f0f4ff 0%, #fff 100%)', borderBottom: '1px solid #E2E8F0' }}>
              <div
                className="rounded-full flex items-center justify-center font-bold text-white"
                style={{ width: 56, height: 56, background: '#4361EE', fontSize: 20 }}
              >
                {selectedUser.avatar}
              </div>
              <div className="font-bold text-slate-800 mt-2 text-center" style={{ fontSize: 15 }}>{selectedUser.name}</div>
              <div style={{ color: '#64748b', fontSize: 12, marginTop: 2 }}>{selectedUser.email}</div>
              <div style={{ color: '#94a3b8', fontSize: 11, marginTop: 1 }}>{selectedUser.phone}</div>
              <div className="flex gap-3 mt-4">
                <div className="text-center">
                  <div className="font-bold text-slate-800" style={{ fontSize: 18 }}>{selectedUser.points.toLocaleString()}</div>
                  <div style={{ color: '#94a3b8', fontSize: 10 }}>Points</div>
                </div>
                <div style={{ width: 1, background: '#E2E8F0' }} />
                <div className="text-center">
                  <div className="font-bold text-slate-800" style={{ fontSize: 18 }}>{selectedUser.reports}</div>
                  <div style={{ color: '#94a3b8', fontSize: 10 }}>Reports</div>
                </div>
                <div style={{ width: 1, background: '#E2E8F0' }} />
                <div className="text-center">
                  <div className="font-bold text-slate-800" style={{ fontSize: 18 }}>{selectedUser.badges.length}</div>
                  <div style={{ color: '#94a3b8', fontSize: 10 }}>Badges</div>
                </div>
              </div>
            </div>

            <div className="px-4 py-3 space-y-3">
              {/* Badges */}
              <div>
                <div className="font-semibold text-slate-800 mb-2" style={{ fontSize: 12 }}>Badges</div>
                <div className="flex flex-wrap gap-1.5">
                  {selectedUser.badges.length > 0 ? selectedUser.badges.map((b) => (
                    <span key={b} style={{ fontSize: 11, padding: '2px 8px', borderRadius: 20, background: '#eff6ff', color: '#4361EE', fontWeight: 600 }}>
                      {b}
                    </span>
                  )) : (
                    <span style={{ fontSize: 11, color: '#94a3b8' }}>No badges yet</span>
                  )}
                </div>
              </div>

              {/* Recent reports */}
              <div>
                <div className="font-semibold text-slate-800 mb-2" style={{ fontSize: 12 }}>Recent Reports</div>
                <div className="space-y-1.5">
                  {mockReports.slice(0, 3).map((r) => (
                    <div key={r.id} className="flex items-center gap-2 rounded-lg p-2" style={{ background: '#f8fafc' }}>
                      <div style={{ width: 6, height: 6, borderRadius: '50%', background: r.severity === 'critical' ? '#EF4444' : r.severity === 'high' ? '#F97316' : '#22C55E', flexShrink: 0 }} />
                      <span className="flex-1 truncate" style={{ fontSize: 11, color: '#475569' }}>{r.title}</span>
                      <span style={{ fontSize: 10, color: '#94a3b8', textTransform: 'capitalize' }}>{r.status}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Actions */}
            <div className="px-4 pb-4 space-y-2" style={{ marginTop: 4 }}>
              <button
                className="w-full font-semibold rounded-xl transition-colors"
                style={{ padding: '9px', fontSize: 13, background: selectedUser.status === 'active' ? '#fff7ed' : '#f0fdf4', color: selectedUser.status === 'active' ? '#ea580c' : '#15803d', border: `1.5px solid ${selectedUser.status === 'active' ? '#fed7aa' : '#bbf7d0'}` }}
              >
                {selectedUser.status === 'active' ? '⏸ Suspend Account' : '▶ Activate Account'}
              </button>
              <button
                className="w-full font-semibold rounded-xl transition-colors"
                style={{ padding: '9px', fontSize: 13, background: '#fee2e2', color: '#dc2626', border: '1.5px solid #fecaca' }}
              >
                🗑 Delete Account
              </button>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  )
}
