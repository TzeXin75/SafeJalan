import { useState } from 'react'
import MobileShell from '@/components/MobileShell'

interface Props {
  onNavigate: (screen: string) => void
}

export default function LoginScreen({ onNavigate }: Props) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPw, setShowPw] = useState(false)

  return (
    <MobileShell>
      {/* Status bar */}
      <div className="bg-[#0F172A] pt-12 pb-6 px-5 flex flex-col items-center">
        <div className="flex items-center gap-2 mb-1">
          <div className="w-8 h-8 rounded-xl bg-[#4361EE] flex items-center justify-center">
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white">
              <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4z" />
            </svg>
          </div>
          <span className="text-white font-bold text-xl tracking-tight">SafeJalan</span>
        </div>
        <p className="text-slate-400 text-xs">Road Safety Community Platform</p>
      </div>

      <div className="bg-[#F8FAFC] rounded-t-3xl flex-1 px-6 pt-8 pb-6 -mt-4">
        {/* Illustration */}
        <div className="flex justify-center mb-6">
          <img
            src="https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=320&h=160&fit=crop&auto=format"
            alt="Road safety"
            className="w-60 h-32 object-cover rounded-2xl"
          />
        </div>

        <h2 className="text-2xl font-bold text-[#1E293B] mb-1">Welcome back</h2>
        <p className="text-slate-500 text-sm mb-6">Sign in to your account</p>

        {/* Fields */}
        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-1.5">Email</label>
            <div className="flex items-center border border-[#E2E8F0] rounded-xl bg-white px-3 gap-2 focus-within:border-[#4361EE] transition-colors">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
                <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z" />
              </svg>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="flex-1 py-3 text-sm bg-transparent outline-none text-[#1E293B] placeholder-slate-400"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#1E293B] mb-1.5">Password</label>
            <div className="flex items-center border border-[#E2E8F0] rounded-xl bg-white px-3 gap-2 focus-within:border-[#4361EE] transition-colors">
              <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
                <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z" />
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
                  <path d={showPw ? 'M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z' : 'M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z'} />
                </svg>
              </button>
            </div>
          </div>
        </div>

        <button
          onClick={() => onNavigate('user-map')}
          className="mt-6 w-full bg-[#4361EE] hover:bg-[#3451d4] text-white font-semibold py-3.5 rounded-xl transition-colors shadow-md shadow-[#4361EE]/30"
        >
          Login
        </button>

        <div className="mt-4 text-center">
          <button className="text-[#4361EE] text-sm font-medium hover:underline">
            Forgot Password?
          </button>
        </div>

        <div className="mt-4 text-center text-sm text-slate-500">
          Don&apos;t have an account?{' '}
          <button
            onClick={() => onNavigate('user-register')}
            className="text-[#4361EE] font-semibold hover:underline"
          >
            Register
          </button>
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
