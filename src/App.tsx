import { useState } from 'react'

import Entry from '@/screens/Entry'

import LoginScreen from '@/screens/user/LoginScreen'
import RegisterScreen from '@/screens/user/RegisterScreen'
import MapScreen from '@/screens/user/MapScreen'
import ReportDamage from '@/screens/user/ReportDamage'
import ReportDetail from '@/screens/user/ReportDetail'
import Connectivity from '@/screens/user/Connectivity'
import Leaderboard from '@/screens/user/Leaderboard'
import Profile from '@/screens/user/Profile'

import AdminLogin from '@/screens/admin/AdminLogin'
import AdminDashboard from '@/screens/admin/AdminDashboard'
import ManageUsers from '@/screens/admin/ManageUsers'
import ManageReports from '@/screens/admin/ManageReports'
import RiskHeatmap from '@/screens/admin/RiskHeatmap'
import Statistics from '@/screens/admin/Statistics'

type Screen =
  | 'entry'
  | 'user-login'
  | 'user-register'
  | 'user-map'
  | 'user-report-damage'
  | 'user-report-detail'
  | 'user-connectivity'
  | 'user-leaderboard'
  | 'user-profile'
  | 'admin-login'
  | 'admin-dashboard'
  | 'admin-users'
  | 'admin-reports'
  | 'admin-heatmap'
  | 'admin-statistics'

export default function App() {
  const [screen, setScreen] = useState<Screen>('entry')

  const nav = (s: string) => setScreen(s as Screen)

  switch (screen) {
    case 'entry':
      return <Entry onNavigate={nav} />

    // User screens
    case 'user-login':
      return <LoginScreen onNavigate={nav} />
    case 'user-register':
      return <RegisterScreen onNavigate={nav} />
    case 'user-map':
      return <MapScreen onNavigate={nav} />
    case 'user-report-damage':
      return <ReportDamage onNavigate={nav} />
    case 'user-report-detail':
      return <ReportDetail onNavigate={nav} />
    case 'user-connectivity':
      return <Connectivity onNavigate={nav} />
    case 'user-leaderboard':
      return <Leaderboard onNavigate={nav} />
    case 'user-profile':
      return <Profile onNavigate={nav} />

    // Admin screens
    case 'admin-login':
      return <AdminLogin onNavigate={nav} />
    case 'admin-dashboard':
      return <AdminDashboard onNavigate={nav} />
    case 'admin-users':
      return <ManageUsers onNavigate={nav} />
    case 'admin-reports':
      return <ManageReports onNavigate={nav} />
    case 'admin-heatmap':
      return <RiskHeatmap onNavigate={nav} />
    case 'admin-statistics':
      return <Statistics onNavigate={nav} />

    default:
      return <Entry onNavigate={nav} />
  }
}
