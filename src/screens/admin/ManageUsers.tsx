import { useState } from 'react'
import MobileShell from '@/components/MobileShell'
import AdminMobileNav from '@/components/AdminMobileNav'
import { users, type User } from '@/data/mockData'

interface Props {
  onNavigate: (screen: string) => void
}

function UserDrawer({ user, onClose }: { user: User; onClose: () => void }) {
  return (
    <div className="absolute inset-0 bg-white z-20 flex flex-col overflow-y-auto no-scrollbar">
      {/* Header */}
      <div className="bg-[#0F172A] pt-12 pb-5 px-5 flex items-center gap-3">
        <button onClick={onClose}>
          <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white">
            <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
          </svg>
        </button>
        <span className="text-white font-bold text-lg">User Profile</span>
      </div>

      <div className="flex-1 bg-[#F8FAFC] px-4 py-5 space-y-4">
        {/* Avatar + info */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] p-5 flex flex-col items-center text-center shadow-sm">
          <img src={user.avatar} alt={user.name} className="w-20 h-20 rounded-full object-cover ring-4 ring-[#4361EE]/20 mb-3 bg-slate-100" />
          <p className="font-bold text-[#1E293B] text-lg">{user.name}</p>
          <p className="text-slate-400 text-sm">{user.email}</p>
          <p className="text-slate-400 text-xs">{user.phone}</p>
          <span className={`mt-2 text-xs font-semibold px-2.5 py-1 rounded-full ${user.status === 'Active' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}`}>
            {user.status}
          </span>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-2.5">
          {[
            { label: 'Points', value: user.points, color: '#4361EE' },
            { label: 'Reports', value: user.reports, color: '#1E293B' },
            { label: 'Badges', value: user.badges.length, color: '#F97316' },
          ].map((s) => (
            <div key={s.label} className="bg-white rounded-2xl border border-[#E2E8F0] p-3 text-center shadow-sm">
              <p className="font-bold text-lg" style={{ color: s.color }}>{s.value}</p>
              <p className="text-xs text-slate-400">{s.label}</p>
            </div>
          ))}
        </div>

        {/* Badges */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
          <p className="text-xs font-semibold text-slate-500 mb-2">BADGES</p>
          <div className="flex flex-wrap gap-2">
            {user.badges.map((b) => (
              <span key={b} className="text-xs bg-blue-50 text-[#4361EE] font-semibold px-2.5 py-1 rounded-full">{b}</span>
            ))}
          </div>
        </div>

        {/* Details */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm space-y-2.5">
          <p className="text-xs font-semibold text-slate-500 mb-1">ACCOUNT DETAILS</p>
          {[
            ['Member Since', user.joinDate],
            ['Account Status', user.status],
            ['Total Verifications', String(user.reports * 3)],
          ].map(([k, v]) => (
            <div key={k} className="flex items-center justify-between text-sm">
              <span className="text-slate-400">{k}</span>
              <span className="font-semibold text-[#1E293B]">{v}</span>
            </div>
          ))}
        </div>

        {/* Actions */}
        <div className="space-y-2">
          <button className="w-full py-3 bg-[#F97316]/10 text-[#F97316] font-semibold rounded-xl text-sm hover:bg-[#F97316]/20 transition-colors">
            {user.status === 'Active' ? 'Suspend User' : 'Activate User'}
          </button>
          <button className="w-full py-3 bg-red-50 text-red-600 font-semibold rounded-xl text-sm hover:bg-red-100 transition-colors">
            Delete Account
          </button>
        </div>
      </div>
    </div>
  )
}

export default function ManageUsers({ onNavigate }: Props) {
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState('All')
  const [selected, setSelected] = useState<User | null>(null)

  const filtered = users.filter((u) => {
    const matchSearch = u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase())
    const matchFilter = filter === 'All' || u.status === filter
    return matchSearch && matchFilter
  })

  return (
    <MobileShell>
      <div className="flex flex-col h-full relative">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-4 px-5">
          <h1 className="text-white font-bold text-lg">Manage Users</h1>
          <p className="text-slate-400 text-xs mt-0.5">{users.length} registered users</p>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] px-4 py-4 space-y-3">
          {/* Search + filter */}
          <div className="flex gap-2">
            <div className="flex-1 flex items-center gap-2 border border-[#E2E8F0] rounded-xl bg-white px-3 focus-within:border-[#4361EE] transition-colors">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
                <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
              </svg>
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search users…"
                className="flex-1 py-2.5 text-sm bg-transparent outline-none text-[#1E293B] placeholder-slate-400"
              />
            </div>
            <select
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              className="border border-[#E2E8F0] rounded-xl bg-white px-3 py-2.5 text-sm text-slate-600 outline-none"
            >
              {['All', 'Active', 'Suspended'].map((f) => <option key={f}>{f}</option>)}
            </select>
          </div>

          {/* User cards */}
          <div className="space-y-2.5">
            {filtered.map((u) => (
              <div key={u.id} className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
                <div className="flex items-center gap-3 mb-3">
                  <img src={u.avatar} alt={u.name} className="w-11 h-11 rounded-full object-cover bg-slate-100 shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-[#1E293B] text-sm truncate">{u.name}</p>
                    <p className="text-xs text-slate-400 truncate">{u.email}</p>
                  </div>
                  <span className={`text-xs font-semibold px-2 py-0.5 rounded-full shrink-0 ${u.status === 'Active' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}`}>
                    {u.status}
                  </span>
                </div>

                <div className="flex items-center gap-4 text-xs text-slate-500 mb-3">
                  <span><span className="font-semibold text-[#4361EE]">{u.points}</span> pts</span>
                  <span><span className="font-semibold text-[#1E293B]">{u.reports}</span> reports</span>
                  <span className="text-slate-400">Since {u.joinDate.slice(0, 7)}</span>
                </div>

                <div className="flex gap-2">
                  <button
                    onClick={() => setSelected(u)}
                    className="flex-1 py-2 text-xs font-semibold text-[#4361EE] bg-blue-50 rounded-xl hover:bg-blue-100 transition-colors"
                  >
                    View
                  </button>
                  <button className="flex-1 py-2 text-xs font-semibold text-[#F97316] bg-orange-50 rounded-xl hover:bg-orange-100 transition-colors">
                    {u.status === 'Active' ? 'Suspend' : 'Activate'}
                  </button>
                  <button className="flex-1 py-2 text-xs font-semibold text-[#EF4444] bg-red-50 rounded-xl hover:bg-red-100 transition-colors">
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <AdminMobileNav active="admin-users" onNavigate={(s) => onNavigate(s)} />

        {/* User detail drawer */}
        {selected && (
          <UserDrawer user={selected} onClose={() => setSelected(null)} />
        )}
      </div>
    </MobileShell>
  )
}
