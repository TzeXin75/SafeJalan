interface Props {
  onNavigate: (screen: string) => void
}

export default function Entry({ onNavigate }: Props) {
  return (
    <div
      className="min-h-screen flex flex-col items-center justify-center p-8 relative overflow-hidden"
      style={{ background: 'linear-gradient(160deg, #1e3a5f 0%, #0F172A 60%, #0c111f 100%)' }}
    >
      {/* Background glow */}
      <div
        className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[400px] pointer-events-none"
        style={{ background: 'radial-gradient(ellipse at 50% 0%, rgba(67,97,238,0.25) 0%, transparent 70%)' }}
      />

      {/* ── Top-right Admin button ── */}
      <button
        onClick={() => onNavigate('admin-login')}
        className="absolute top-5 right-5 flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all duration-200 hover:bg-white/10 active:scale-95"
        style={{ background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)', color: '#94a3b8' }}
      >
        <svg viewBox="0 0 24 24" style={{ width: 13, height: 13 }} fill="currentColor">
          <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z" />
        </svg>
        Admin
      </button>

      {/* Logo */}
      <div className="relative flex flex-col items-center mb-10">
        <div
          className="w-20 h-20 rounded-3xl flex items-center justify-center mb-5 shadow-2xl"
          style={{
            background: 'linear-gradient(135deg, #4361EE 0%, #2e4fd4 100%)',
            boxShadow: '0 20px 60px rgba(67,97,238,0.5)',
          }}
        >
          <svg viewBox="0 0 24 24" style={{ width: 44, height: 44 }} fill="white">
            <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm13.5-9l1.96 2.5H17V9.5h2.5zm-1.5 9c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z" />
          </svg>
        </div>
        <h1
          className="text-white font-extrabold text-center"
          style={{ fontSize: 42, letterSpacing: '-0.03em', lineHeight: 1 }}
        >
          SafeJalan
        </h1>
        <p className="text-slate-400 mt-3 text-sm text-center max-w-xs leading-relaxed">
          Community-powered road safety reporting for a safer Malaysia
        </p>
      </div>

      {/* Stats row */}
      <div className="flex items-center gap-3 mb-10 flex-wrap justify-center">
        {[
          { value: '1,284', label: 'Citizens' },
          { value: '263', label: 'Reports' },
          { value: '148', label: 'Resolved' },
        ].map((s) => (
          <div
            key={s.label}
            className="flex items-center gap-2 px-4 py-2 rounded-full"
            style={{ background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.08)' }}
          >
            <span className="text-white font-bold text-sm">{s.value}</span>
            <span className="text-slate-500 text-xs">{s.label}</span>
          </div>
        ))}
      </div>

      {/* Main CTA card */}
      <div
        className="w-full max-w-sm rounded-3xl p-6"
        style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.08)' }}
      >
        {/* Feature list */}
        <div className="space-y-3 mb-6">
          {[
            'Report road damage with photo & GPS',
            'Live map of nearby incidents',
            'Earn points & climb the leaderboard',
            'Track your report status in real-time',
          ].map((f) => (
            <div key={f} className="flex items-center gap-3">
              <div
                className="w-5 h-5 rounded-full flex items-center justify-center shrink-0"
                style={{ background: 'rgba(67,97,238,0.25)' }}
              >
                <svg viewBox="0 0 24 24" style={{ width: 11, height: 11 }} fill="#4361EE">
                  <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                </svg>
              </div>
              <span className="text-slate-300 text-sm">{f}</span>
            </div>
          ))}
        </div>

        {/* User CTA */}
        <button
          onClick={() => onNavigate('user-login')}
          className="w-full py-4 rounded-2xl font-bold text-white text-base transition-all duration-200 active:scale-[0.98] hover:brightness-110"
          style={{
            background: 'linear-gradient(135deg, #4361EE 0%, #2e4fd4 100%)',
            boxShadow: '0 8px 32px rgba(67,97,238,0.45)',
          }}
        >
          Get Started
        </button>

        <button
          onClick={() => onNavigate('user-login')}
          className="w-full mt-3 py-3 rounded-2xl font-semibold text-sm transition-all duration-200 active:scale-[0.98]"
          style={{
            background: 'rgba(255,255,255,0.06)',
            border: '1px solid rgba(255,255,255,0.1)',
            color: '#94a3b8',
          }}
        >
          Sign In
        </button>
      </div>

      <p className="mt-8 text-slate-700 text-xs text-center">
        © 2026 SafeJalan · Road Safety Community Platform · Malaysia
      </p>
    </div>
  )
}
