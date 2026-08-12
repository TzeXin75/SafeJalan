type AdminScreen =
  | 'admin-dashboard'
  | 'admin-users'
  | 'admin-reports'
  | 'admin-heatmap'
  | 'admin-statistics'

interface Props {
  active: AdminScreen
  onNavigate: (screen: AdminScreen) => void
}

const items: { id: AdminScreen; label: string; icon: string }[] = [
  {
    id: 'admin-dashboard',
    label: 'Home',
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
    icon: 'M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z',
  },
  {
    id: 'admin-statistics',
    label: 'Stats',
    icon: 'M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6z',
  },
]

export default function AdminMobileNav({ active, onNavigate }: Props) {
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
