import MobileShell from '@/components/MobileShell'
import BottomNav from '@/components/BottomNav'
import { leaderboard } from '@/data/mockData'

interface Props {
  onNavigate: (screen: string) => void
}

const podiumColors = [
  { bg: '#FFD700', text: '#92400e', ring: '#FBBF24' },
  { bg: '#E5E7EB', text: '#374151', ring: '#9CA3AF' },
  { bg: '#F97316', text: '#7c2d12', ring: '#FB923C' },
]

const podiumOrder = [1, 0, 2] // silver, gold, bronze position order

export default function Leaderboard({ onNavigate }: Props) {
  const top3 = leaderboard.slice(0, 3)
  const rest = leaderboard.slice(3)

  return (
    <MobileShell>
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="bg-gradient-to-b from-[#0F172A] to-[#1e3a5f] pt-12 pb-8 px-5 text-center">
          <div className="text-5xl mb-2">🏆</div>
          <h1 className="text-white font-bold text-xl">Leaderboard</h1>
          <p className="text-slate-400 text-xs mt-1">Top reporters this month</p>
        </div>

        <div className="flex-1 overflow-y-auto no-scrollbar bg-[#F8FAFC]">
          {/* Podium */}
          <div className="bg-gradient-to-b from-[#1e3a5f] to-[#F8FAFC] px-4 pb-6">
            <div className="flex items-end justify-center gap-3">
              {podiumOrder.map((idx) => {
                const user = top3[idx]
                const col = podiumColors[idx]
                const heights = ['h-24', 'h-32', 'h-20']
                const size = idx === 0 ? 'w-14 h-14 text-lg' : 'w-12 h-12 text-sm'
                return (
                  <div key={idx} className="flex flex-col items-center gap-2">
                    <div
                      className={`${size} rounded-full flex items-center justify-center font-bold text-white ring-4 overflow-hidden`}
                      style={{ ringColor: col.ring }}
                    >
                      <img
                        src={`https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format&seed=${idx}`}
                        alt={user.name}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="text-center">
                      <p className="text-white text-xs font-semibold leading-tight max-w-16 truncate">{user.name.split(' ')[0]}</p>
                      <p className="text-slate-300 text-xs">{user.points} pts</p>
                    </div>
                    <div
                      className={`w-16 ${heights[idx]} rounded-t-xl flex items-start justify-center pt-2`}
                      style={{ backgroundColor: col.bg }}
                    >
                      <span className="text-lg font-bold" style={{ color: col.text }}>
                        {user.badge}
                      </span>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          {/* Rankings list */}
          <div className="px-4 pb-4 space-y-2">
            <p className="text-xs font-semibold text-slate-400 mb-3">FULL RANKING</p>
            {leaderboard.map((u, i) => (
              <div
                key={i}
                className="bg-white rounded-2xl border border-[#E2E8F0] p-3 flex items-center gap-3"
              >
                <div
                  className="w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm shrink-0"
                  style={{
                    backgroundColor: i < 3 ? ['#FFD700', '#E5E7EB', '#F97316'][i] : '#F1F5F9',
                    color: i < 3 ? ['#92400e', '#374151', '#7c2d12'][i] : '#64748B',
                  }}
                >
                  {u.rank}
                </div>
                <div className="w-9 h-9 rounded-full overflow-hidden shrink-0 bg-slate-100">
                  <img
                    src={`https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=48&h=48&fit=crop&auto=format&seed=${i * 7}`}
                    alt={u.name}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-sm text-[#1E293B] truncate">{u.name}</p>
                  <p className="text-xs text-slate-400">{u.reports} reports</p>
                </div>
                <div className="text-right">
                  <p className="font-bold text-[#4361EE] text-sm">{u.points}</p>
                  <p className="text-xs text-slate-400">points</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <BottomNav active="user-leaderboard" onNavigate={(s) => onNavigate(s)} />
      </div>
    </MobileShell>
  )
}
