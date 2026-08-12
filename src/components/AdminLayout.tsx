import { useState, type ReactNode } from 'react'

type AdminScreen =
  | 'admin-dashboard'
  | 'admin-users'
  | 'admin-reports'
  | 'admin-heatmap'
  | 'admin-statistics'

interface Props {
  active: AdminScreen
  onNavigate: (screen: AdminScreen | 'admin-login' | 'entry') => void
  children: ReactNode
}

const navItems: { id: AdminScreen; label: string; icon: string }[] = [
  {
    id: 'admin-dashboard',
    label: 'Dashboard',
    icon: 'M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z',
  },
  {
    id: 'admin-users',
    label: 'Users',
    icon: 'M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z',
  },
  {
    id: 'admin-reports',
    label: 'Reports',
    icon: 'M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 9h-2V5h2v6zm0 4h-2v-2h2v2z',
  },
  {
    id: 'admin-heatmap',
    label: 'Heatmap',
    icon: 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z',
  },
  {
    id: 'admin-statistics',
    label: 'Statistics',
    icon: 'M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6z',
  },
]

export default function AdminLayout({ active, onNavigate, children }: Props) {
  const [collapsed, setCollapsed] = useState(false)

  return (
    <div className="flex h-screen bg-[#F8FAFC] overflow-hidden">
      {/* Sidebar */}
      <aside
        className="flex flex-col bg-[#0F172A] text-white transition-all duration-300 shrink-0"
        style={{ width: collapsed ? 64 : 220 }}
      >
        {/* Logo */}
        <div className="flex items-center gap-3 px-4 py-5 border-b border-white/10">
          <div className="w-8 h-8 shrink-0 rounded-lg bg-[#4361EE] flex items-center justify-center">
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white">
              <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
            </svg>
          </div>
          {!collapsed && (
            <span className="font-bold text-sm tracking-wide whitespace-nowrap">
              SafeJalan Admin
            </span>
          )}
        </div>

        {/* Nav items */}
        <nav className="flex-1 py-4 space-y-1 px-2">
          {navItems.map((item) => {
            const isActive = active === item.id
            return (
              <button
                key={item.id}
                onClick={() => onNavigate(item.id)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-[#4361EE] text-white'
                    : 'text-slate-400 hover:bg-white/10 hover:text-white'
                }`}
              >
                <svg viewBox="0 0 24 24" className="w-5 h-5 shrink-0 fill-current">
                  <path d={item.icon} />
                </svg>
                {!collapsed && (
                  <span className="truncate whitespace-nowrap">{item.label}</span>
                )}
              </button>
            )
          })}
        </nav>

        {/* Bottom: collapse + logout */}
        <div className="px-2 pb-4 space-y-1 border-t border-white/10 pt-4">
          <button
            onClick={() => setCollapsed(!collapsed)}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-slate-400 hover:bg-white/10 hover:text-white text-sm font-medium transition-all"
          >
            <svg viewBox="0 0 24 24" className="w-5 h-5 shrink-0 fill-current">
              <path d={collapsed ? 'M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z' : 'M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z'} />
            </svg>
            {!collapsed && <span>Collapse</span>}
          </button>
          <button
            onClick={() => onNavigate('entry')}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-slate-400 hover:bg-red-500/20 hover:text-red-400 text-sm font-medium transition-all"
          >
            <svg viewBox="0 0 24 24" className="w-5 h-5 shrink-0 fill-current">
              <path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z" />
            </svg>
            {!collapsed && <span>Logout</span>}
          </button>
        </div>
      </aside>

      {/* Main content area */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top bar */}
        <header className="bg-white border-b border-[#E2E8F0] px-6 py-3 flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl px-3 py-2 w-72">
            <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
              <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
            </svg>
            <input
              type="text"
              placeholder="Search anything…"
              className="bg-transparent text-sm text-[#1E293B] placeholder-slate-400 outline-none w-full"
            />
          </div>
          <div className="flex items-center gap-4">
            <button className="relative p-2 rounded-xl hover:bg-[#F8FAFC] transition-colors">
              <svg viewBox="0 0 24 24" className="w-5 h-5 fill-slate-500">
                <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z" />
              </svg>
              <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full" />
            </button>
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-full bg-[#4361EE] flex items-center justify-center text-white text-xs font-bold">
                AD
              </div>
              <div className="text-sm">
                <p className="font-semibold text-[#1E293B] leading-none">Admin</p>
                <p className="text-slate-400 text-xs">Super Admin</p>
              </div>
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto no-scrollbar p-6">{children}</main>
      </div>
    </div>
  )
}
