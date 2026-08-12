import { useState } from 'react'
import MobileShell from '@/components/MobileShell'

interface Props {
  onNavigate: (screen: string) => void
}

function Field({
  label,
  type = 'text',
  placeholder,
  icon,
}: {
  label: string
  type?: string
  placeholder: string
  icon: string
}) {
  const [val, setVal] = useState('')
  return (
    <div>
      <label className="block text-xs font-semibold text-[#1E293B] mb-1.5">{label}</label>
      <div className="flex items-center border border-[#E2E8F0] rounded-xl bg-white px-3 gap-2 focus-within:border-[#4361EE] transition-colors">
        <svg viewBox="0 0 24 24" className="w-4 h-4 fill-slate-400 shrink-0">
          <path d={icon} />
        </svg>
        <input
          type={type}
          value={val}
          onChange={(e) => setVal(e.target.value)}
          placeholder={placeholder}
          className="flex-1 py-3 text-sm bg-transparent outline-none text-[#1E293B] placeholder-slate-400"
        />
      </div>
    </div>
  )
}

export default function RegisterScreen({ onNavigate }: Props) {
  return (
    <MobileShell>
      {/* Header */}
      <div className="bg-[#0F172A] pt-12 pb-5 px-5 flex items-center gap-3">
        <button onClick={() => onNavigate('user-login')}>
          <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white">
            <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
          </svg>
        </button>
        <span className="text-white font-bold text-lg">Create Account</span>
      </div>

      <div className="bg-[#F8FAFC] rounded-t-3xl flex-1 px-6 pt-7 pb-8 -mt-4">
        <h2 className="text-xl font-bold text-[#1E293B] mb-1">Join SafeJalan</h2>
        <p className="text-slate-500 text-sm mb-6">Help make Malaysian roads safer</p>

        <div className="space-y-4">
          <Field
            label="Full Name"
            placeholder="Ahmad Razif"
            icon="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"
          />
          <Field
            label="Email"
            type="email"
            placeholder="your@email.com"
            icon="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"
          />
          <Field
            label="Password"
            type="password"
            placeholder="Min. 8 characters"
            icon="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2z"
          />
          <Field
            label="Confirm Password"
            type="password"
            placeholder="Repeat password"
            icon="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2z"
          />
          <Field
            label="Phone Number"
            type="tel"
            placeholder="+60 12-345 6789"
            icon="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"
          />
        </div>

        {/* Terms */}
        <label className="flex items-start gap-2 mt-5">
          <input type="checkbox" className="mt-0.5 accent-[#4361EE]" />
          <span className="text-xs text-slate-500">
            I agree to the{' '}
            <span className="text-[#4361EE] font-medium">Terms of Service</span> and{' '}
            <span className="text-[#4361EE] font-medium">Privacy Policy</span>
          </span>
        </label>

        <button
          onClick={() => onNavigate('user-map')}
          className="mt-5 w-full bg-[#4361EE] hover:bg-[#3451d4] text-white font-semibold py-3.5 rounded-xl transition-colors shadow-md shadow-[#4361EE]/30"
        >
          Create Account
        </button>

        <div className="mt-4 text-center text-sm text-slate-500">
          Already have an account?{' '}
          <button
            onClick={() => onNavigate('user-login')}
            className="text-[#4361EE] font-semibold hover:underline"
          >
            Login
          </button>
        </div>
      </div>
    </MobileShell>
  )
}
