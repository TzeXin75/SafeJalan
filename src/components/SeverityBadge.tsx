import { type Severity } from '../data/mockData'

const cfg = {
  low: { label: 'Low', bg: '#dcfce7', text: '#15803d', dot: '#22C55E' },
  medium: { label: 'Medium', bg: '#fef9c3', text: '#a16207', dot: '#FACC15' },
  high: { label: 'High', bg: '#ffedd5', text: '#c2410c', dot: '#F97316' },
  critical: { label: 'Critical', bg: '#fee2e2', text: '#b91c1c', dot: '#EF4444' },
}

export default function SeverityBadge({ severity, size = 'sm' }: { severity: Severity; size?: 'sm' | 'md' }) {
  const c = cfg[severity]
  return (
    <span
      className="inline-flex items-center gap-1.5 font-semibold rounded-full"
      style={{
        background: c.bg,
        color: c.text,
        padding: size === 'md' ? '4px 12px' : '2px 8px',
        fontSize: size === 'md' ? 13 : 11,
      }}
    >
      <span style={{ width: 6, height: 6, borderRadius: '50%', background: c.dot, flexShrink: 0, display: 'inline-block' }} />
      {c.label}
    </span>
  )
}
