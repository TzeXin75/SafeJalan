Your current UI style is very clean and modern. For Figma AI, the best approach is to give it **screen-by-screen prompts** instead of a single sentence. Below is a complete design specification that matches your current user interface, so the admin screens will have the same visual identity.

---

# SafeJalan UI Theme (Apply to ALL Screens)

## Style

* Modern mobile application
* Clean government/community reporting app
* Minimalist interface
* Rounded corners (12–16px)
* Soft shadows on cards
* White background
* Dark navy top app bar
* Blue primary buttons
* Simple line icons
* Plenty of whitespace
* Google Material Design style

## Color Palette

Primary Blue

```
#4361EE
```

Dark Navbar

```
#0F172A
```

Background

```
#F8FAFC
```

Card

```
#FFFFFF
```

Text

```
#1E293B
```

Border

```
#E2E8F0
```

Low Severity

```
Green #22C55E
```

Medium

```
Yellow #FACC15
```

High

```
Orange #F97316
```

Critical

```
Red #EF4444
```

---

# USER SIDE

---

# 1. Login Screen

Prompt

> Design a modern mobile login screen for SafeJalan. Place a dark navy header with the SafeJalan logo. Add a centered road safety illustration. Below it, include Email and Password input fields with rounded corners. Add a blue "Login" button. Below the button include "Forgot Password?" and "Register". White background, minimal style, Material Design.

---

# 2. Register Screen

Prompt

> Create a registration page matching the SafeJalan theme. Include Full Name, Email, Password, Confirm Password, Phone Number. Add a blue Register button and Login link. Rounded text fields with icons.

---

# 3. Map Screen

(Almost same as yours)

Prompt

> Design a mobile dashboard with OpenStreetMap occupying most of the screen. Show colored road damage markers (green, yellow, orange, red). Include zoom buttons on left. Add floating blue "Report Damage" button at bottom center. Under the map display horizontally scrollable report cards showing severity, title, location, verification count and status. Bottom navigation includes Map, Report, Risk, Connectivity, Leaderboard and Profile.

---

# 4. Report Damage

Prompt

> Create a road damage reporting page. Large upload photo area with camera icon. Auto-detected GPS location card. Dropdown Category. Severity selector with Low, Medium, High, Critical buttons. Description text area. Blue Submit Report button. White background with rounded cards.

---

# 5. Report Detail

Prompt

> Design a report detail page. Large road damage image on top. Display report title, location, category, severity badge, submission time and reporter. Add verification section with two buttons: "Still Exists" and "Resolved". Show verification statistics. Display report status timeline below.

---

# 6. Connectivity

Prompt

> Design a connectivity reporting screen. Two large toggle buttons: Poor Signal and No Wi-Fi. Signal strength slider. Carrier input field. Notes text box. Blue "Report Gap" button. Show recent connectivity reports below.

---

# 7. Leaderboard

Prompt

> Design a leaderboard page. Large trophy icon at top. Show Top 3 contributors with gold, silver and bronze badges. Display ranking list underneath with avatar, username, points and badges. Modern blue and white theme.

---

# 8. Profile

Prompt

> Design a profile page with circular avatar, username and email. Display two statistic cards for Points and Reports. Badge section with earned badges. Report history cards below showing title, location and report status. Bottom navigation fixed.

---

# ADMIN SIDE

Unlike User, Admin is a web dashboard.

Use desktop resolution.

---

# 1. Admin Login

Prompt

> Design a modern admin login page for SafeJalan. Split layout. Left side contains road safety illustration. Right side contains login card with SafeJalan Admin logo, Email field, Password field, Remember Me checkbox, Login button and Forgot Password link. Navy and blue color scheme.

---

# 2. Admin Dashboard

Prompt

> Create a professional web dashboard for SafeJalan administration. Left sidebar navigation with Dashboard, Users, Reports, Risk Heatmap, Statistics, Logout. Top bar includes admin profile and notification icon. Main content contains six statistic cards: Total Users, Total Reports, Active Reports, Resolved Reports, Connectivity Reports and Pending Reports. Below display a line chart for monthly reports, pie chart for report categories and recent activity table. White cards with soft shadows and blue highlights.

Layout

```
-----------------------------------------

Sidebar

Dashboard

Users

Reports

Heatmap

Statistics

Logout

-----------------------------------------

Top Bar

Search

Notification

Admin

-----------------------------------------

Cards

Users

Reports

Resolved

Pending

Connectivity

Heatmap Alerts

-----------------------------------------

Charts

Monthly Reports

Pie Chart

-----------------------------------------

Recent Reports Table

-----------------------------------------
```

---

# 3. Manage Users

Prompt

> Design a user management dashboard. Sidebar remains visible. Main page contains searchable user table with profile image, username, email, reports submitted, points, account status and join date. Include filter dropdown. Each row has View, Suspend, Activate and Delete buttons. Clicking View opens a side panel displaying user profile, badges, report history and verification count.

---

# 4. Manage Reports

Prompt

> Design a report management page. Large searchable table showing Report ID, image thumbnail, category, severity, location, reporter, submission date and status. Filters for category, severity and status. Each report includes action buttons View, Approve, Reject, Edit, Delete and Mark Resolved. Clicking View opens a detailed panel displaying uploaded image, GPS map, report description, verification history and admin notes.

---

# 5. Risk Heatmap

Prompt

> Create an analytics page displaying an interactive city map with colored heatmap overlays representing road damage density. High-risk areas appear red, medium orange, low yellow. Left panel contains filters for date, district, severity and category. Right panel displays Top Risk Areas, Active Incidents, Average Resolution Time and Heatmap Legend. Clean GIS-inspired dashboard using white cards and blue navigation.

Layout

```
--------------------------------------

Sidebar

--------------------------------------

Heatmap

(Map occupies 70%)

--------------------------------------

Right Statistics

High Risk

Medium Risk

Low Risk

Top Hotspots

--------------------------------------
```

---

# 6. Statistics

Prompt

> Design a statistics dashboard for SafeJalan. Include multiple analytics cards and charts. Show bar chart for reports by month, pie chart for report categories, donut chart for severity distribution, line chart for report trends, leaderboard of top contributors, average resolution time, active users and report completion rate. White dashboard cards with blue accents and responsive layout.

---

# 7. User Detail Popup

Prompt

> Design a side drawer displaying complete user profile. Include avatar, username, email, phone number, points, badges, report history, verification count, account status and recent activities. Add Suspend, Activate and Delete buttons at bottom.

---

# 8. Report Detail Popup

Prompt

> Design a report detail page for administrators. Large uploaded road image. GPS location map. Report information including category, severity, AI prediction, reporter, date submitted and duplicate detection results. Show community verification timeline. Add admin notes section and action buttons: Approve, Reject, Edit Category, Change Severity, Mark Resolved and Delete.

---

## Final User Flow

### User Side

```
Login
│
├── Register
│
├── Home Map
│      ├── Report Detail
│      └── Report Damage
│
├── Connectivity
│
├── Leaderboard
│
└── Profile
       └── My Reports
```

### Admin Side

```
Admin Login
│
└── Dashboard
      ├── Manage Users
      │      └── User Detail
      │
      ├── Manage Reports
      │      └── Report Detail
      │
      ├── Risk Heatmap
      │
      ├── Statistics
      │
      └── Logout
```

These prompts are detailed enough for **Figma AI** to generate mockups that closely match your existing SafeJalan user screens while maintaining a consistent design language across the new admin interface.
