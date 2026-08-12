import MobileShell from '@/components/MobileShell'
import BottomNav from '@/components/BottomNav'
import { reports } from '@/data/mockData'
import { SeverityBadge, StatusBadge } from '@/components/Badge'

interface Props {
  onNavigate: (screen: string) => void
}

const badges = [
  { icon: '🚀', name: 'Pioneer', desc: 'First 100 users' },
  { icon: '✅', name: 'Verified', desc: 'Report accepted' },
  { icon: '🏆', name: 'Top Contributor', desc: '1000+ points' },
]

export default function Profile({ onNavigate }: Props) {
  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="bg-[#0F172A] pt-12 pb-14 px-5 flex items-center justify-between">
          <h1 className="text-white font-bold text-lg">My Profile</h1>
          <button>
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-slate-400">
              <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z" />
            </svg>
          </button>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC] -mt-8">
          {/* Avatar card */}
          <div className="mx-4 bg-white rounded-2xl border border-[#E2E8F0] p-5 flex flex-col items-center shadow-sm">
            <div className="w-20 h-20 rounded-full overflow-hidden ring-4 ring-[#4361EE]/20 mb-3">
              <img
                src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format"
                alt="Ahmad Razif"
                className="w-full h-full object-cover"
              />
            </div>
            <p className="font-bold text-[#1E293B] text-lg">Ahmad Razif</p>
            <p className="text-slate-400 text-sm">ahmad.razif@gmail.com</p>
            <p className="text-slate-400 text-xs mt-0.5">Member since Sep 2025</p>
          </div>

          <div className="px-4 py-4 space-y-4">
            {/* Stats */}
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-[#4361EE] rounded-2xl p-4 text-center">
                <p className="text-white/70 text-xs font-medium">Total Points</p>
                <p className="text-white font-bold text-2xl">1,240</p>
                <p className="text-white/60 text-xs">Rank #1</p>
              </div>
              <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 text-center">
                <p className="text-slate-400 text-xs font-medium">Reports</p>
                <p className="text-[#1E293B] font-bold text-2xl">18</p>
                <p className="text-slate-400 text-xs">16 approved</p>
              </div>
            </div>

            {/* Badges */}
            <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4">
              <p className="font-semibold text-[#1E293B] text-sm mb-3">Earned Badges</p>
              <div className="flex gap-3">
                {badges.map((b) => (
                  <div key={b.name} className="flex-1 flex flex-col items-center gap-1.5 bg-[#F8FAFC] rounded-xl p-3">
                    <span className="text-2xl">{b.icon}</span>
                    <p className="text-xs font-semibold text-[#1E293B] text-center">{b.name}</p>
                    <p className="text-[10px] text-slate-400 text-center leading-tight">{b.desc}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Report history */}
            <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4">
              <p className="font-semibold text-[#1E293B] text-sm mb-3">Report History</p>
              <div className="space-y-3">
                {reports.slice(0, 4).map((r) => (
                  <button
                    key={r.id}
                    onClick={() => onNavigate('user-report-detail')}
                    className="w-full flex items-start gap-3 text-left p-2.5 rounded-xl hover:bg-[#F8FAFC] transition-colors"
                  >
                    <img
                      src={r.imageUrl}
                      alt={r.title}
                      className="w-12 h-12 rounded-xl object-cover shrink-0 bg-slate-100"
                    />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-[#1E293B] line-clamp-1">{r.title}</p>
                      <p className="text-xs text-slate-400 truncate">{r.location}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <SeverityBadge severity={r.severity} />
                        <StatusBadge status={r.status} />
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            </div>

            {/* Sign out */}
            <button
              onClick={() => onNavigate('entry')}
              className="w-full border border-red-200 text-red-500 font-semibold py-3 rounded-xl hover:bg-red-50 transition-colors text-sm"
            >
              Sign Out
            </button>
          </div>
        </div>

        <BottomNav active="user-profile" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
