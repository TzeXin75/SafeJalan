import BottomNav from '../../components/BottomNav'
import { leaderboardUsers } from '../../data/mockData'

interface Props {
  navigate: (screen: string) => void
}

const MEDAL_COLORS = ['#F59E0B', '#94a3b8', '#92400e']
const MEDAL_BG = ['#fef3c7', '#f1f5f9', '#fff7ed']
const RANK_LABEL = ['🥇', '🥈', '🥉']

export default function LeaderboardScreen({ navigate }: Props) {
  return (
    <div className="flex flex-col h-full">
      {/* App bar */}
      <div
        className="flex-shrink-0 flex items-center justify-between px-5"
        style={{ height: 56, background: '#0F172A' }}
      >
        <span className="text-white font-bold" style={{ fontSize: 16 }}>Leaderboard</span>
        <button style={{ color: '#94a3b8', fontSize: 12, fontWeight: 600 }}>This Month</button>
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Top banner */}
        <div
          className="flex flex-col items-center py-6 px-5"
          style={{ background: 'linear-gradient(180deg, #0F172A 0%, #1e3a5f 100%)' }}
        >
          <div style={{ fontSize: 52 }}>🏆</div>
          <div className="text-white font-bold mt-2" style={{ fontSize: 18 }}>Top Contributors</div>
          <div style={{ color: '#94a3b8', fontSize: 12, marginTop: 2 }}>January 2024</div>

          {/* Top 3 podium */}
          <div className="flex items-end gap-3 mt-6 w-full max-w-xs">
            {/* 2nd place */}
            <div className="flex-1 flex flex-col items-center gap-2">
              <div className="relative">
                <div
                  className="rounded-full flex items-center justify-center text-white font-bold"
                  style={{ width: 48, height: 48, background: '#94a3b8', fontSize: 16 }}
                >
                  {leaderboardUsers[1].avatar}
                </div>
                <div className="absolute -top-1 -right-1 text-base">🥈</div>
              </div>
              <div className="text-center">
                <div className="text-white font-semibold" style={{ fontSize: 11 }}>{leaderboardUsers[1].name.split(' ')[0]}</div>
                <div style={{ color: '#94a3b8', fontSize: 10 }}>{leaderboardUsers[1].points} pts</div>
              </div>
              <div
                className="w-full rounded-t-lg flex items-center justify-center font-bold"
                style={{ height: 44, background: '#94a3b8', color: '#fff', fontSize: 18 }}
              >2</div>
            </div>

            {/* 1st place */}
            <div className="flex-1 flex flex-col items-center gap-2">
              <div className="relative">
                <div
                  className="rounded-full flex items-center justify-center text-white font-bold ring-4"
                  style={{ width: 60, height: 60, background: '#4361EE', fontSize: 20, outline: '3px solid #F59E0B' }}
                >
                  {leaderboardUsers[0].avatar}
                </div>
                <div className="absolute -top-1 -right-1 text-xl">🥇</div>
              </div>
              <div className="text-center">
                <div className="text-white font-bold" style={{ fontSize: 12 }}>{leaderboardUsers[0].name.split(' ')[0]}</div>
                <div style={{ color: '#FACC15', fontSize: 11, fontWeight: 600 }}>{leaderboardUsers[0].points} pts</div>
              </div>
              <div
                className="w-full rounded-t-lg flex items-center justify-center font-bold"
                style={{ height: 60, background: '#F59E0B', color: '#fff', fontSize: 20 }}
              >1</div>
            </div>

            {/* 3rd place */}
            <div className="flex-1 flex flex-col items-center gap-2">
              <div className="relative">
                <div
                  className="rounded-full flex items-center justify-center text-white font-bold"
                  style={{ width: 48, height: 48, background: '#a16207', fontSize: 16 }}
                >
                  {leaderboardUsers[2].avatar}
                </div>
                <div className="absolute -top-1 -right-1 text-base">🥉</div>
              </div>
              <div className="text-center">
                <div className="text-white font-semibold" style={{ fontSize: 11 }}>{leaderboardUsers[2].name.split(' ')[0]}</div>
                <div style={{ color: '#94a3b8', fontSize: 10 }}>{leaderboardUsers[2].points} pts</div>
              </div>
              <div
                className="w-full rounded-t-lg flex items-center justify-center font-bold"
                style={{ height: 32, background: '#92400e', color: '#fff', fontSize: 18 }}
              >3</div>
            </div>
          </div>
        </div>

        {/* Rankings list */}
        <div className="px-4 py-3 space-y-2">
          <div className="font-bold text-slate-800 mb-3" style={{ fontSize: 14 }}>Full Rankings</div>
          {leaderboardUsers.map((user) => {
            const isTop3 = user.rank <= 3
            return (
              <div
                key={user.rank}
                className="flex items-center gap-3 rounded-2xl p-3"
                style={{
                  background: isTop3 ? MEDAL_BG[user.rank - 1] : '#fff',
                  border: `1px solid ${isTop3 ? 'transparent' : '#E2E8F0'}`,
                }}
              >
                <div className="flex-shrink-0 w-8 text-center">
                  {isTop3 ? (
                    <span style={{ fontSize: 20 }}>{RANK_LABEL[user.rank - 1]}</span>
                  ) : (
                    <span className="font-bold" style={{ fontSize: 15, color: '#94a3b8' }}>#{user.rank}</span>
                  )}
                </div>
                <div
                  className="flex-shrink-0 rounded-full flex items-center justify-center font-bold text-white"
                  style={{
                    width: 40,
                    height: 40,
                    background: isTop3 ? MEDAL_COLORS[user.rank - 1] : '#4361EE',
                    fontSize: 14,
                  }}
                >
                  {user.avatar}
                </div>
                <div className="flex-1">
                  <div className="font-bold text-slate-800" style={{ fontSize: 13 }}>{user.name}</div>
                  <div style={{ fontSize: 11, color: '#94a3b8' }}>{user.reports} reports · {user.badges} badges</div>
                </div>
                <div className="text-right">
                  <div className="font-bold" style={{ fontSize: 15, color: '#4361EE' }}>{user.points}</div>
                  <div style={{ fontSize: 10, color: '#94a3b8' }}>pts</div>
                </div>
              </div>
            )
          })}
        </div>
        <div style={{ height: 8 }} />
      </div>

      <BottomNav active="leaderboard" navigate={navigate} />
    </div>
  )
}
