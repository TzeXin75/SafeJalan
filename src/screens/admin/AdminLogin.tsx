import { useState } from 'react'
import MobileShell from '@/components/MobileShell'

interface Props {
  onNavigate: (screen: string) => void
}

export default function AdminLogin({ onNavigate }: Props) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [remember, setRemember] = useState(false)
  const [showPw, setShowPw] = useState(false)

  return (
    <MobileShell>
      {/* Header */}
      <div className="bg-[#0F172A] pt-12 pb-8 px-5 flex flex-col items-center">
        <div className="w-14 h-14 rounded-2xl bg-[#4361EE] flex items-center justify-center mb-3 shadow-lg shadow-[#4361EE]/40">
          <svg viewBox="0 0 24 24" className="w-8 h-8 fill-white">
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z" />
          </svg>
        </div>
        <h1 className="text-white font-bold text-xl tracking-tight">SafeJalan Admin</h1>
        <p className="text-slate-400 text-xs mt-1">Administration Console</p>
      </div>

      <div className="bg-[#F8FAFC] rounded-t-3xl px-6 pt-7 pb-8 -mt-4 flex-1">
        <h2 className="text-xl font-bold text-[#1E293B] mb-1">Admin Sign In</h2>
        <p className="text-slate-500 text-sm mb-6">Access restricted to authorised personnel</p>

        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-1.5">Email Address</label>
            <div className="flex items-center border border-[#E2E8F0] rounded-xl bg-white px-3 gap-2 focus-within:border-[#4361EE] transition-colors">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
                <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z" />
              </svg>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@safejalan.gov.my"
                className="flex-1 py-3 text-sm bg-transparent outline-none text-[#1E293B] placeholder-slate-400"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-1.5">Password</label>
            <div className="flex items-center border border-[#E2E8F0] rounded-xl bg-white px-3 gap-2 focus-within:border-[#4361EE] transition-colors">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
                <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2z" />
              </svg>
              <input
                type={showPw ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="flex-1 py-3 text-sm bg-transparent outline-none text-[#1E293B] placeholder-slate-400"
              />
              <button onClick={() => setShowPw(!showPw)}>
                <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400">
                  <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z" />
                </svg>
              </button>
            </div>
          </div>

          <div className="flex items-center justify-between pt-1">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={remember}
                onChange={(e) => setRemember(e.target.checked)}
                className="accent-[#4361EE] w-4 h-4"
              />
              <span className="text-sm text-slate-600">Remember me</span>
            </label>
            <button className="text-sm text-[#4361EE] font-medium hover:underline">
              Forgot Password?
            </button>
          </div>
        </div>

        <button
          onClick={() => onNavigate('admin-dashboard')}
          className="mt-6 w-full bg-[#4361EE] hover:bg-[#3451d4] text-white font-semibold py-3.5 rounded-xl transition-colors shadow-md shadow-[#4361EE]/30"
        >
          Sign In
        </button>

        {/* Security notice */}
        <div className="mt-5 flex items-start gap-2 bg-amber-50 border border-amber-200 rounded-xl p-3">
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-amber-500 shrink-0 mt-0.5">
            <path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z" />
          </svg>
          <p className="text-xs text-amber-700 leading-relaxed">
            This console is for authorised SafeJalan administrators only. Unauthorised access is prohibited.
          </p>
        </div>

        <button
          onClick={() => onNavigate('entry')}
          className="mt-4 w-full text-slate-400 text-sm hover:text-slate-600 transition-colors py-1"
        >
          ← Back to main
        </button>
      </div>
    </MobileShell>
  )
}
