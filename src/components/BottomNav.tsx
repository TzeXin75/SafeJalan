type Screen =
  | 'user-map'
  | 'user-report-damage'
  | 'user-connectivity'
  | 'user-leaderboard'
  | 'user-profile'

interface Props {
  active: Screen
  onNavigate: (screen: Screen) => void
}

const items: { id: Screen; label: string; icon: string }[] = [
  { id: 'user-map', label: 'Map', icon: 'M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z' },
  { id: 'user-report-damage', label: 'Report', icon: 'M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c.55 0 1 .45 1 1v4c0 .55-.45 1-1 1s-1-.45-1-1V7c0-.55.45-1 1-1zm0 8c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z' },
  { id: 'user-connectivity', label: 'Network', icon: 'M1 9l2 2c4.97-4.97 13.03-4.97 18 0l2-2C16.93 2.93 7.08 2.93 1 9zm8 8l3 3 3-3c-1.65-1.66-4.34-1.66-6 0zm-4-4 2 2c2.76-2.76 7.24-2.76 10 0l2-2C15.14 9.14 8.87 9.14 5 13z' },
  { id: 'user-leaderboard', label: 'Rank', icon: 'M19 5h-2V3H7v2H5c-1.1 0-2 .9-2 2v1c0 2.55 1.92 4.63 4.39 4.94.63 1.5 1.98 2.63 3.61 2.96V19H7v2h10v-2h-4v-3.1c1.63-.33 2.98-1.46 3.61-2.96C19.08 12.63 21 10.55 21 8V7c0-1.1-.9-2-2-2z' },
  { id: 'user-profile', label: 'Profile', icon: 'M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z' },
]

export default function BottomNav({ active, onNavigate }: Props) {
  return (
    <div
      className="flex items-center border-t border-[#E2E8F0] bg-white"
      style={{ paddingBottom: 'env(safe-area-inset-bottom, 8px)' }}
    >
      {items.map((item) => {
        const isActive = active === item.id
        return (
          <button
            key={item.id}
            onClick={() => onNavigate(item.id)}
            className="flex-1 flex flex-col items-center gap-0.5 py-2 transition-colors"
          >
            <svg
              viewBox="0 0 24 24"
              className="w-5 h-5"
              fill={isActive ? '#4361EE' : '#94a3b8'}
            >
              <path d={item.icon} />
            </svg>
            <span
              className="text-[10px] font-medium"
              style={{ color: isActive ? '#4361EE' : '#94a3b8' }}
            >
              {item.label}
            </span>
          </button>
        )
      })}
    </div>
  )
}
