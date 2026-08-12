export type Severity = 'Low' | 'Medium' | 'High' | 'Critical'
export type ReportStatus = 'Pending' | 'Active' | 'Resolved' | 'Rejected'

export interface Report {
  id: string
  title: string
  category: string
  severity: Severity
  location: string
  reporter: string
  date: string
  status: ReportStatus
  verifications: number
  description: string
  imageUrl: string
  coordinates: { lat: number; lng: number }
}

export interface User {
  id: string
  name: string
  email: string
  phone: string
  points: number
  reports: number
  status: 'Active' | 'Suspended'
  joinDate: string
  avatar: string
  badges: string[]
}

export const reports: Report[] = [
  {
    id: 'RPT-001',
    title: 'Deep Pothole near MRT Station',
    category: 'Pothole',
    severity: 'Critical',
    location: 'Jalan Ampang, KL',
    reporter: 'Ahmad Razif',
    date: '2026-07-20',
    status: 'Active',
    verifications: 14,
    description: 'Large pothole approximately 40cm wide and 15cm deep, posing serious risk to motorcyclists especially at night.',
    imageUrl: 'https://images.unsplash.com/photo-1584436055955-c41af83e4870?w=600&h=400&fit=crop&auto=format',
    coordinates: { lat: 3.158, lng: 101.712 },
  },
  {
    id: 'RPT-002',
    title: 'Road Surface Cracking',
    category: 'Road Damage',
    severity: 'High',
    location: 'Jalan PJ 5/1, Petaling Jaya',
    reporter: 'Nurul Hana',
    date: '2026-07-19',
    status: 'Pending',
    verifications: 7,
    description: 'Multiple cracks spreading across two lanes. Surface has deteriorated significantly after recent heavy rain.',
    imageUrl: 'https://images.unsplash.com/photo-1513828583688-c52646db42da?w=600&h=400&fit=crop&auto=format',
    coordinates: { lat: 3.107, lng: 101.607 },
  },
  {
    id: 'RPT-003',
    title: 'Missing Road Divider',
    category: 'Infrastructure',
    severity: 'Medium',
    location: 'Lebuhraya SPRINT, Shah Alam',
    reporter: 'Tan Wei Ming',
    date: '2026-07-18',
    status: 'Active',
    verifications: 5,
    description: 'Road divider missing along 20m stretch on highway. Risk of head-on collision.',
    imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=600&h=400&fit=crop&auto=format',
    coordinates: { lat: 3.07, lng: 101.52 },
  },
  {
    id: 'RPT-004',
    title: 'Faded Lane Markings',
    category: 'Road Markings',
    severity: 'Low',
    location: 'Jalan Klang Lama, KL',
    reporter: 'Priya Nair',
    date: '2026-07-17',
    status: 'Resolved',
    verifications: 3,
    description: 'Lane markings almost completely faded. Drivers merging unsafely especially in wet conditions.',
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=400&fit=crop&auto=format',
    coordinates: { lat: 3.118, lng: 101.672 },
  },
  {
    id: 'RPT-005',
    title: 'Broken Traffic Light',
    category: 'Traffic Signals',
    severity: 'Critical',
    location: 'Jalan Tun Razak, KL',
    reporter: 'Faizal Hakim',
    date: '2026-07-16',
    status: 'Resolved',
    verifications: 22,
    description: 'Traffic light out of service. Traffic police deployed but permanent fix needed urgently.',
    imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600&h=400&fit=crop&auto=format',
    coordinates: { lat: 3.162, lng: 101.704 },
  },
  {
    id: 'RPT-006',
    title: 'Waterlogging After Rain',
    category: 'Flooding',
    severity: 'High',
    location: 'Jalan Duta, KL',
    reporter: 'Siti Aminah',
    date: '2026-07-15',
    status: 'Active',
    verifications: 9,
    description: 'Road floods to 30cm depth during heavy rain. Drainage system blocked by debris.',
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=400&fit=crop&auto=format',
    coordinates: { lat: 3.178, lng: 101.681 },
  },
]

export const users: User[] = [
  {
    id: 'USR-001',
    name: 'Ahmad Razif',
    email: 'ahmad.razif@gmail.com',
    phone: '+60 12-345 6789',
    points: 1240,
    reports: 18,
    status: 'Active',
    joinDate: '2025-09-10',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format',
    badges: ['Pioneer', 'Verified Reporter', 'Top Contributor'],
  },
  {
    id: 'USR-002',
    name: 'Nurul Hana',
    email: 'nurul.hana@outlook.com',
    phone: '+60 11-222 3344',
    points: 980,
    reports: 12,
    status: 'Active',
    joinDate: '2025-10-02',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop&auto=format',
    badges: ['Active Citizen', 'Verified Reporter'],
  },
  {
    id: 'USR-003',
    name: 'Tan Wei Ming',
    email: 'tweiming@hotmail.com',
    phone: '+60 16-778 9900',
    points: 760,
    reports: 9,
    status: 'Active',
    joinDate: '2025-11-14',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&auto=format',
    badges: ['Active Citizen'],
  },
  {
    id: 'USR-004',
    name: 'Priya Nair',
    email: 'priya.n@yahoo.com',
    phone: '+60 17-654 3210',
    points: 510,
    reports: 6,
    status: 'Suspended',
    joinDate: '2025-12-01',
    avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&auto=format',
    badges: ['Pioneer'],
  },
  {
    id: 'USR-005',
    name: 'Faizal Hakim',
    email: 'faizal.hakim@gmail.com',
    phone: '+60 19-111 2233',
    points: 1050,
    reports: 15,
    status: 'Active',
    joinDate: '2025-09-25',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&auto=format',
    badges: ['Verified Reporter', 'Top Contributor'],
  },
]

export const monthlyData = [
  { month: 'Feb', reports: 24, resolved: 18 },
  { month: 'Mar', reports: 38, resolved: 30 },
  { month: 'Apr', reports: 45, resolved: 40 },
  { month: 'May', reports: 52, resolved: 44 },
  { month: 'Jun', reports: 61, resolved: 55 },
  { month: 'Jul', reports: 43, resolved: 38 },
]

export const categoryData = [
  { name: 'Pothole', value: 38 },
  { name: 'Road Damage', value: 24 },
  { name: 'Traffic Signals', value: 15 },
  { name: 'Infrastructure', value: 13 },
  { name: 'Flooding', value: 10 },
]

export const severityData = [
  { name: 'Critical', value: 18, color: '#EF4444' },
  { name: 'High', value: 32, color: '#F97316' },
  { name: 'Medium', value: 28, color: '#FACC15' },
  { name: 'Low', value: 22, color: '#22C55E' },
]

export const leaderboard = [
  { rank: 1, name: 'Ahmad Razif', points: 1240, reports: 18, badge: '🥇' },
  { rank: 2, name: 'Faizal Hakim', points: 1050, reports: 15, badge: '🥈' },
  { rank: 3, name: 'Nurul Hana', points: 980, reports: 12, badge: '🥉' },
  { rank: 4, name: 'Tan Wei Ming', points: 760, reports: 9, badge: '' },
  { rank: 5, name: 'Priya Nair', points: 510, reports: 6, badge: '' },
  { rank: 6, name: 'Siti Aminah', points: 430, reports: 5, badge: '' },
  { rank: 7, name: 'Ravi Kumar', points: 370, reports: 4, badge: '' },
  { rank: 8, name: 'Lee Mei Ling', points: 310, reports: 4, badge: '' },
]

export const connectivityReports = [
  { area: 'Bukit Bintang, KL', type: 'Poor Signal', carrier: 'Celcom', time: '2h ago' },
  { area: 'Subang Jaya, Selangor', type: 'No Wi-Fi', carrier: 'Maxis', time: '4h ago' },
  { area: 'Chow Kit, KL', type: 'Poor Signal', carrier: 'Digi', time: '6h ago' },
]

export const SEVERITY_COLORS: Record<string, string> = {
  Low: '#22C55E',
  Medium: '#FACC15',
  High: '#F97316',
  Critical: '#EF4444',
}

export const SEVERITY_BG: Record<string, string> = {
  Low: 'bg-[#22C55E]/10 text-[#16a34a]',
  Medium: 'bg-[#FACC15]/20 text-[#a16207]',
  High: 'bg-[#F97316]/10 text-[#ea580c]',
  Critical: 'bg-[#EF4444]/10 text-[#dc2626]',
}

export const STATUS_STYLE: Record<string, string> = {
  Active: 'bg-blue-50 text-blue-700',
  Pending: 'bg-yellow-50 text-yellow-700',
  Resolved: 'bg-green-50 text-green-700',
  Rejected: 'bg-red-50 text-red-700',
}

// Aliases for screens that use alternate export names
export const mockReports = reports
export const mockUsers = users
export const leaderboardUsers = leaderboard
export const monthlyReportData = monthlyData
