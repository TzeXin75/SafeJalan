import { useState } from 'react'

interface Props {
  onLogin: () => void
  onSwitchToUser: () => void
}

export default function AdminLoginScreen({ onLogin, onSwitchToUser }: Props) {
  const [email, setEmail] = useState('admin@safejalan.my')
  const [password, setPassword] = useState('admin123')
  const [remember, setRemember] = useState(false)

  return (
    <div className="min-h-screen flex">
      {/* Left panel - illustration */}
      <div
        className="hidden lg:flex flex-col justify-between flex-1 p-12"
        style={{ background: 'linear-gradient(135deg, #0F172A 0%, #1e3a5f 60%, #4361EE 100%)' }}
      >
        <div className="flex items-center gap-3">
          <div
            className="flex items-center justify-center rounded-xl font-bold text-white"
            style={{ width: 42, height: 42, background: 'rgba(255,255,255,0.15)', fontSize: 16 }}
          >
            SJ
          </div>
          <div>
            <div className="text-white font-bold text-xl">SafeJalan</div>
            <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: 12 }}>Administration Portal</div>
          </div>
        </div>

        <div>
          <div style={{ fontSize: 80, marginBottom: 24 }}>🛣️</div>
          <div className="text-white font-bold" style={{ fontSize: 36, lineHeight: 1.2 }}>
            Manage Road Safety<br />Across Malaysia
          </div>
          <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: 15, marginTop: 16, lineHeight: 1.7 }}>
            Monitor reports, manage users, and analyze road safety data in real-time. Keep communities safe with actionable insights.
          </div>

          <div className="flex gap-6 mt-8">
            {[
              { value: '2,840', label: 'Total Reports' },
              { value: '98.4%', label: 'Uptime' },
              { value: '12,500+', label: 'Users' },
            ].map((s) => (
              <div key={s.label}>
                <div className="text-white font-bold text-2xl">{s.value}</div>
                <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: 12, marginTop: 2 }}>{s.label}</div>
              </div>
            ))}
          </div>
        </div>

        <div style={{ color: 'rgba(255,255,255,0.3)', fontSize: 12 }}>
          © 2024 SafeJalan. All rights reserved.
        </div>
      </div>

      {/* Right panel - login form */}
      <div
        className="flex-1 lg:max-w-md flex items-center justify-center p-8"
        style={{ background: '#fff' }}
      >
        <div className="w-full max-w-sm">
          {/* Mobile logo */}
          <div className="lg:hidden flex items-center gap-2 mb-8">
            <div
              className="flex items-center justify-center rounded-xl font-bold text-white"
              style={{ width: 36, height: 36, background: '#4361EE', fontSize: 14 }}
            >
              SJ
            </div>
            <div className="font-bold text-slate-800 text-xl">SafeJalan Admin</div>
          </div>

          <div className="mb-8">
            <div className="font-bold text-slate-800" style={{ fontSize: 28 }}>Welcome back</div>
            <div style={{ color: '#64748b', fontSize: 14, marginTop: 4 }}>Sign in to the admin dashboard</div>
          </div>

          <div className="space-y-4">
            {/* Email */}
            <div>
              <label className="block font-semibold mb-1.5" style={{ fontSize: 12, color: '#475569' }}>EMAIL ADDRESS</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full outline-none text-slate-800"
                style={{
                  padding: '12px 14px',
                  border: '1.5px solid #E2E8F0',
                  borderRadius: 12,
                  fontSize: 14,
                  background: '#f8fafc',
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = '#4361EE')}
                onBlur={(e) => (e.currentTarget.style.borderColor = '#E2E8F0')}
              />
            </div>

            {/* Password */}
            <div>
              <label className="block font-semibold mb-1.5" style={{ fontSize: 12, color: '#475569' }}>PASSWORD</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full outline-none text-slate-800"
                style={{
                  padding: '12px 14px',
                  border: '1.5px solid #E2E8F0',
                  borderRadius: 12,
                  fontSize: 14,
                  background: '#f8fafc',
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = '#4361EE')}
                onBlur={(e) => (e.currentTarget.style.borderColor = '#E2E8F0')}
              />
            </div>

            {/* Remember + forgot */}
            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={remember}
                  onChange={(e) => setRemember(e.target.checked)}
                  style={{ accentColor: '#4361EE' }}
                />
                <span style={{ fontSize: 13, color: '#475569' }}>Remember me</span>
              </label>
              <button style={{ fontSize: 13, color: '#4361EE', fontWeight: 600 }}>Forgot password?</button>
            </div>

            <button
              onClick={onLogin}
              className="w-full font-bold text-white rounded-xl transition-transform hover:scale-[1.02] active:scale-98"
              style={{ padding: '14px', background: '#4361EE', fontSize: 15, boxShadow: '0 4px 14px rgba(67,97,238,0.4)', marginTop: 8 }}
            >
              Sign In to Dashboard
            </button>
          </div>

          <div className="mt-6 pt-6 text-center" style={{ borderTop: '1px solid #E2E8F0' }}>
            <button onClick={onSwitchToUser} style={{ color: '#64748b', fontSize: 13 }}>
              ← Back to <span style={{ color: '#4361EE', fontWeight: 600 }}>User App</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
