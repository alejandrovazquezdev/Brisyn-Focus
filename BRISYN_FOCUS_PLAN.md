# Brisyn Focus - Project Plan

> A cross-platform Focus & Productivity app built with Flutter

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Target Audience](#target-audience)
3. [Target Platforms](#target-platforms)
4. [Design System](#design-system)
5. [Core Features - Free](#core-features-free)
6. [Gamification System](#gamification-system)
7. [Premium Features - Brisyn Pro](#premium-features-brisyn-pro)
8. [Technical Architecture](#technical-architecture)
9. [Landing Page & Website](#landing-page-website)
10. [Legal - Privacy Policy](#legal-privacy-policy)
11. [Development Roadmap](#development-roadmap)
12. [Tech Stack](#tech-stack)
13. [Project Structure](#project-structure)

---

## Project Overview

**Brisyn Focus** is a professional productivity app designed to help users stay focused, manage their time effectively, and achieve their goals through proven techniques like the Pomodoro method, combined with gamification elements.

**Inspiration Sources:**
- Pomodoro Timer - Time-boxing technique
- Forest - Gamified focus sessions
- Focus To-Do - Tasks + Pomodoro combined
- Toggl Track - Time tracking & analytics

---

## Target Audience

Brisyn Focus is designed for anyone who needs to track and optimize their time:

- **Students** - Studying, exam preparation, homework
- **Professionals** - Deep work, project focus, meetings
- **Remote Workers** - Time management, work-life balance
- **Lifelong Learners** - Reading, online courses, skill development
- **Writers & Creators** - Writing sessions, creative blocks

**Supported Languages:** English, Spanish (more languages planned)

---

## Target Platforms

| Platform | Status | Priority | Distribution |
|----------|--------|----------|--------------|
| Android | Pending | High | Google Play Store |
| iOS | Pending | High | App Store |
| macOS | Pending | Medium | Direct Download / App Store |
| Windows | Pending | Medium | Direct Download / Microsoft Store |
| Linux | Pending | Medium | Direct Download |

---

## Design System

### Philosophy
- **Professional & Clean**: No emojis, only custom SVG icons
- **Minimalist**: Distraction-free interface
- **Dual Theme**: Dark and Light modes
- **User Customizable**: Accent colors selectable by user

### Color Palette

#### Dark Theme (Primary)
```
Background Primary:    #0D0D0D (Near Black)
Background Secondary:  #1A1A1A (Dark Gray)
Surface:              #242424 (Card backgrounds)
Border:               #333333 (Subtle borders)
Text Primary:         #FFFFFF (White)
Text Secondary:       #A0A0A0 (Muted gray)
```

#### Light Theme
```
Background Primary:    #FFFFFF (White)
Background Secondary:  #F5F5F5 (Light Gray)
Surface:              #FAFAFA (Card backgrounds)
Border:               #E0E0E0 (Subtle borders)
Text Primary:         #0D0D0D (Near Black)
Text Secondary:       #666666 (Muted gray)
```

#### Accent Colors (User Selectable)
```
Default Blue:         #3B82F6
Green:                #10B981
Purple:               #8B5CF6
Orange:               #F59E0B
Red:                  #EF4444
Cyan:                 #06B6D4
Pink:                 #EC4899
```

### Typography
- **Primary Font**: Inter (Clean, professional, excellent readability)
- **Monospace**: JetBrains Mono (For timer display)

### Icons
- All icons must be custom SVG
- Consistent stroke width (1.5px - 2px)
- Rounded corners style
- Icon library: Custom set or Lucide/Phosphor style

---

## Core Features (Free)

### 1. Pomodoro Timer
- Customizable focus sessions (default: 25 minutes)
- Short breaks (5 min) & Long breaks (15-30 min)
- Auto-start next session option
- Session counter (track daily pomodoros)
- Audio notifications & alarms
- Background timer support
- Timer presets (Quick 15, Standard 25, Deep 50)

### 2. Task Management
- Create, edit, delete tasks
- Task categories/projects
- Priority levels (High, Medium, Low)
- Due dates
- Link tasks to focus sessions
- Daily task list view
- Mark tasks as complete

### 3. Basic Statistics
- Daily focus time
- Weekly summary
- Tasks completed count
- Current streak counter

### 4. Settings & Customization
- Timer duration customization
- Notification sounds selection
- Dark/Light theme toggle
- Accent color picker
- Language selection (EN/ES)

### 5. User Interface
- Clean, distraction-free design
- Quick-start focus button
- Minimalist dashboard
- Smooth animations

---

## Gamification System

### Free Gamification Features

#### Focus Streaks
- Daily streak counter
- Visual streak indicator on dashboard
- Streak milestone celebrations (7, 30, 100 days)
- Streak protection: Miss one day = streak paused, not lost

#### Achievement Badges
Unlockable badges for milestones:

| Badge | Requirement | Icon Concept |
|-------|-------------|--------------|
| First Focus | Complete first session | Play button |
| Early Bird | Focus before 7 AM | Sunrise |
| Night Owl | Focus after 10 PM | Moon |
| Century | 100 total sessions | Shield with 100 |
| Week Warrior | 7-day streak | Calendar check |
| Month Master | 30-day streak | Trophy |
| Deep Diver | Single 2-hour session | Ocean depth |
| Task Slayer | Complete 50 tasks | Checklist |
| Consistent | Focus 5 days in a row | Chain links |

#### Levels & XP System
- Earn XP for every focus minute (1 min = 1 XP)
- Bonus XP for completing tasks during sessions
- Bonus XP for maintaining streaks
- Level progression with increasing thresholds

| Level | XP Required | Title |
|-------|-------------|-------|
| 1 | 0 | Beginner |
| 2 | 500 | Apprentice |
| 3 | 1,500 | Focused |
| 4 | 3,500 | Dedicated |
| 5 | 7,000 | Expert |
| 6 | 12,000 | Master |
| 7 | 20,000 | Grandmaster |
| 8 | 35,000 | Legend |
| 9 | 60,000 | Mythic |
| 10 | 100,000 | Transcendent |

### Pro Gamification Features

#### Leaderboards
- Weekly leaderboard (resets every Monday)
- Monthly leaderboard
- All-time leaderboard
- Filter by friends only
- Anonymous mode option

#### Focus Challenges
- Weekly challenges with specific goals
- Example challenges:
  - "Focus for 10 hours this week"
  - "Complete 20 tasks"
  - "Maintain a 5-day streak"
- Bonus XP rewards for completion

#### Profile Customization
- Custom profile avatars
- Profile themes/backgrounds
- Display badges on profile
- Share profile achievements

---

## Premium Features - Brisyn Pro

**Pricing: $4.99/month or $39.99/year (33% savings)**

### Cloud Sync & Backup
- Sync data across all devices (mobile, desktop)
- Automatic cloud backup to Firebase
- Restore data on new devices
- Account-based storage
- Offline support with automatic sync when online

### Advanced Analytics & Reports
- Detailed productivity reports
- Monthly/Yearly statistics
- Productivity trends & graphs
- Focus time by project/category
- Peak productivity hours analysis
- Export data (CSV, PDF)
- Insights and recommendations

### Advanced Task Features
- Recurring tasks (daily, weekly, custom)
- Subtasks & checklists
- Task templates
- Kanban board view
- Task notes and attachments

### Smart Reminders System
- **Optimal Time Suggestions**: AI analyzes your history to suggest best focus times
- **Daily Goal Reminders**: "You need 2 more hours to reach your daily goal"
- **Break Reminders**: Prevent burnout with smart break notifications
- **Weekly Review**: Summary notification every Sunday
- **Inactivity Alerts**: "You haven't focused in 3 days. Let's get back on track!"
- **Custom Reminder Scheduling**: Set specific times for focus reminders

### Pro Gamification
- Leaderboards (global, friends)
- Weekly challenges
- Profile customization

---

## Technical Architecture

### Tech Stack Overview

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.x + Dart 3.x |
| State Management | Riverpod |
| Local Database | Isar |
| Backend | Firebase |
| Authentication | Firebase Auth |
| Cloud Database | Cloud Firestore |
| Analytics | Firebase Analytics |
| Payments | RevenueCat |
| Notifications | Firebase Cloud Messaging + Local |

### Firebase Services Used

| Service | Purpose |
|---------|---------|
| Firebase Auth | User authentication (Email, Google, Apple) |
| Cloud Firestore | Real-time database for user data |
| Cloud Functions | Server-side logic, subscription validation |
| Firebase Analytics | User behavior tracking |
| Remote Config | Feature flags, A/B testing |
| Crashlytics | Crash reporting |

### Google Play Console APIs
- Google Play Billing Library
- Google Play Developer API (subscription management)
- Google Play Console API (analytics, reviews)

### App Store Connect APIs
- StoreKit 2 (iOS/macOS purchases)
- App Store Connect API

### Project Structure

```
brisyn_focus/
|-- lib/
|   |-- main.dart
|   |-- app/
|   |   |-- app.dart
|   |   |-- routes.dart
|   |   |-- theme/
|   |       |-- app_theme.dart
|   |       |-- colors.dart
|   |       |-- typography.dart
|   |-- core/
|   |   |-- constants/
|   |   |   |-- app_constants.dart
|   |   |   |-- storage_keys.dart
|   |   |-- services/
|   |   |   |-- audio_service.dart
|   |   |   |-- notification_service.dart
|   |   |   |-- storage_service.dart
|   |   |-- utils/
|   |       |-- date_utils.dart
|   |       |-- formatters.dart
|   |-- features/
|   |   |-- auth/
|   |   |   |-- data/
|   |   |   |-- domain/
|   |   |   |-- presentation/
|   |   |-- timer/
|   |   |   |-- data/
|   |   |   |-- domain/
|   |   |   |-- presentation/
|   |   |-- tasks/
|   |   |   |-- data/
|   |   |   |-- domain/
|   |   |   |-- presentation/
|   |   |-- statistics/
|   |   |   |-- data/
|   |   |   |-- domain/
|   |   |   |-- presentation/
|   |   |-- gamification/
|   |   |   |-- data/
|   |   |   |-- domain/
|   |   |   |-- presentation/
|   |   |-- settings/
|   |   |   |-- data/
|   |   |   |-- domain/
|   |   |   |-- presentation/
|   |   |-- premium/
|   |       |-- data/
|   |       |-- domain/
|   |       |-- presentation/
|   |-- shared/
|   |   |-- widgets/
|   |   |-- models/
|   |   |-- providers/
|   |-- l10n/
|       |-- app_en.arb
|       |-- app_es.arb
|-- assets/
|   |-- icons/          (SVG icons)
|   |-- images/
|   |-- sounds/
|   |-- fonts/
|-- test/
|   |-- unit/
|   |-- widget/
|   |-- integration/
|-- website/            (Landing page - separate)
|   |-- index.html
|   |-- privacy.html
|   |-- css/
|   |-- js/
|   |-- assets/
|-- android/
|-- ios/
|-- macos/
|-- windows/
|-- linux/
|-- docs/
|   |-- ARCHITECTURE.md
|   |-- PRIVACY_POLICY.md
|-- firebase/
|   |-- firestore.rules
|   |-- firestore.indexes.json
|   |-- functions/
|-- pubspec.yaml
|-- analysis_options.yaml
|-- README.md
|-- BRISYN_FOCUS_PLAN.md
```

---

## Landing Page & Website

### Purpose
- Promotional landing page for Brisyn Focus
- App download links (Google Play, App Store, Direct)
- Privacy Policy page
- Hosted on your own server/DNS

### Website Structure

```
website/
|-- index.html          (Main landing page)
|-- privacy.html        (Privacy Policy - EN)
|-- privacidad.html     (Privacy Policy - ES)
|-- css/
|   |-- style.css
|   |-- responsive.css
|-- js/
|   |-- main.js
|   |-- language.js
|-- assets/
|   |-- icons/
|   |-- images/
|   |-- downloads/      (Desktop installers)
|-- downloads/
    |-- brisyn-focus-windows.exe
    |-- brisyn-focus-macos.dmg
    |-- brisyn-focus-linux.AppImage
```

### Landing Page Sections

1. **Hero Section**
   - App name and tagline
   - App mockup/screenshot
   - Download buttons (Play Store, App Store, Desktop)

2. **Features Section**
   - Timer features
   - Task management
   - Statistics
   - Gamification highlights

3. **Premium Section**
   - Brisyn Pro benefits
   - Pricing display

4. **Download Section**
   - Platform-specific download buttons
   - QR code for mobile

5. **Footer**
   - Privacy Policy link
   - Terms of Service link
   - Contact information
   - Social media links
   - Language switcher (EN/ES)

### Design Requirements
- Same design system as app (colors, typography)
- Dark theme default with light option
- Fully responsive (mobile, tablet, desktop)
- Fast loading, optimized assets
- No external dependencies (self-hosted)

---

## Legal - Privacy Policy

### Privacy Policy Requirements

The privacy policy must cover:

1. **Data Collection**
   - Account information (email, name)
   - Usage data (focus sessions, tasks, statistics)
   - Device information (for analytics)
   - Payment information (handled by RevenueCat/stores)

2. **Data Usage**
   - Provide app functionality
   - Sync across devices (Pro users)
   - Improve app experience
   - Send relevant notifications

3. **Data Storage**
   - Firebase servers (Google Cloud)
   - Data encryption in transit and at rest
   - User data retention policies

4. **User Rights**
   - Access their data
   - Export their data
   - Delete their account and data
   - Opt-out of analytics

5. **Third-Party Services**
   - Firebase (Google)
   - RevenueCat
   - Google Play Services
   - Apple Services

6. **Children's Privacy**
   - App not directed at children under 13
   - COPPA compliance

7. **Updates to Policy**
   - Notification of changes
   - Last updated date

### Documents to Create
- Privacy Policy (English)
- Privacy Policy (Spanish)
- Terms of Service (English)
- Terms of Service (Spanish)

---

## Development Roadmap

### Phase 1: Foundation (Weeks 1-3)
- [ ] Set up project architecture (Clean Architecture)
- [ ] Configure Riverpod state management
- [ ] Implement Isar local storage
- [ ] Create design system (colors, typography, theme)
- [ ] Build SVG icon system
- [ ] Implement theming (Dark/Light + accent colors)
- [ ] Set up go_router navigation
- [ ] Create base UI components

### Phase 2: Core Features (Weeks 4-7)
- [ ] Build Pomodoro Timer
  - [ ] Timer logic & state management
  - [ ] Background service (all platforms)
  - [ ] Notifications
  - [ ] Timer UI with presets
  - [ ] Audio service
- [ ] Build Task Management
  - [ ] Task model & storage
  - [ ] CRUD operations
  - [ ] Categories/Projects
  - [ ] Task list UI
- [ ] Basic Statistics
  - [ ] Data tracking service
  - [ ] Daily/Weekly calculations
  - [ ] Statistics dashboard

### Phase 3: Gamification (Weeks 8-9)
- [ ] Implement XP & Levels system
- [ ] Build Streaks tracking
- [ ] Create Achievement badges system
- [ ] Gamification UI components
- [ ] Profile screen

### Phase 4: Platform Polish (Weeks 10-12)
- [ ] UI/UX refinement
- [ ] Platform-specific features
  - [ ] Android: Widgets, notifications
  - [ ] iOS: Widgets, notifications
  - [ ] macOS: Menu bar integration
  - [ ] Windows: System tray
  - [ ] Linux: System tray
- [ ] Accessibility improvements
- [ ] Performance optimization
- [ ] Localization (EN/ES)

### Phase 5: Backend & Auth (Weeks 13-15)
- [ ] Set up Firebase project
- [ ] Implement Firebase Auth
  - [ ] Email/Password
  - [ ] Google Sign-In
  - [ ] Apple Sign-In
- [ ] Design Firestore data structure
- [ ] Implement cloud sync
- [ ] Data migration (local to cloud)
- [ ] Firestore security rules

### Phase 6: Premium Features (Weeks 16-19)
- [ ] Set up RevenueCat
- [ ] Implement subscription system
- [ ] Advanced analytics & reports
- [ ] Advanced task features (recurring, subtasks, kanban)
- [ ] Smart reminders system
- [ ] Leaderboards
- [ ] Weekly challenges

### Phase 7: Website & Legal (Weeks 20-21)
- [ ] Build landing page
- [ ] Create Privacy Policy
- [ ] Create Terms of Service
- [ ] Set up hosting on your server
- [ ] Download page with installers

### Phase 8: Launch Preparation (Weeks 22-24)
- [ ] App Store optimization (ASO)
- [ ] Create store listings (screenshots, descriptions)
- [ ] Beta testing (TestFlight, Google Play Beta)
- [ ] Bug fixes from beta
- [ ] Prepare desktop installers
- [ ] Final QA testing
- [ ] Soft launch
- [ ] Official launch

---

## Tech Stack - Detailed

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^14.0.0
  
  # Local Storage
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  shared_preferences: ^2.2.0
  
  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0
  firebase_remote_config: ^5.0.0
  firebase_messaging: ^15.0.0
  
  # Authentication
  google_sign_in: ^6.2.0
  sign_in_with_apple: ^6.1.0
  
  # Payments
  purchases_flutter: ^7.0.0
  
  # UI & Design
  flutter_svg: ^2.0.10
  google_fonts: ^6.2.0
  fl_chart: ^0.68.0
  shimmer: ^3.0.0
  
  # Notifications
  flutter_local_notifications: ^17.0.0
  
  # Background Services
  workmanager: ^0.5.2
  
  # Audio
  just_audio: ^0.9.37
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.4.0
  equatable: ^2.0.5
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  path_provider: ^2.1.0
  url_launcher: ^6.3.0
  share_plus: ^9.0.0
  package_info_plus: ^8.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  isar_generator: ^3.1.0
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
```

---

## Success Metrics (KPIs)

### User Metrics
- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- User Retention (Day 1, 7, 30)
- Average session duration
- Focus sessions completed per user
- Tasks completed per user

### Business Metrics
- Monthly Recurring Revenue (MRR)
- Conversion rate (Free to Pro)
- Customer Lifetime Value (LTV)
- Churn rate
- App Store ratings (target: 4.5+)

### Engagement Metrics
- Average daily focus time
- Streak length distribution
- Badge unlock rates
- Feature usage rates

---

## Action Items - Immediate Next Steps

1. [x] Create project plan (this document)
2. [ ] Set up project folder structure
3. [ ] Configure pubspec.yaml with dependencies
4. [ ] Create design system files (colors, typography, theme)
5. [ ] Build initial SVG icon set
6. [ ] Create Firebase project
7. [ ] Begin Phase 1 development

---

*Document created: December 25, 2025*
*Last updated: December 25, 2025*
*Version: 2.0*
