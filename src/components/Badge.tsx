import { SEVERITY_BG, STATUS_STYLE } from '@/data/mockData'

export function SeverityBadge({ severity }: { severity: string }) {
  return (
    <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${SEVERITY_BG[severity] ?? 'bg-slate-100 text-slate-600'}`}>
      {severity}
    </span>
  )
}

export function StatusBadge({ status }: { status: string }) {
  return (
    <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${STATUS_STYLE[status] ?? 'bg-slate-100 text-slate-600'}`}>
      {status}
    </span>
  )
}
