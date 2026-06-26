# 🌐 WorkSphere — Freelancer Marketplace App

A full-stack mobile application built with **Flutter**, **Firebase**, and **BLoC** architecture that connects clients with freelancers. Clients can post projects, receive proposals, and hire talent. Freelancers can browse opportunities, submit bids, and manage their professional profile.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| State Management | flutter_bloc |
| Backend | Firebase (Firestore, Auth, Storage) |
| Architecture | BLoC + Repository Pattern |
| Image Handling | cached_network_image, image_picker |
| Date Formatting | intl |

---

## 📁 Folder Structure

```
lib/
├── model/
│   ├── projectModel.dart
│   ├── bidModel.dart
│   └── freelancerModel.dart
├── repository/
│   ├── projectRepository.dart
│   ├── bidRepository.dart
│   └── freelancerRepository.dart
├── viewmodel/
│   ├── Bloc/
│   │   ├── projectBloc.dart
│   │   ├── bidBloc.dart
│   │   └── freelancerProfileBloc.dart
│   ├── Events/
│   │   ├── projectEvent.dart
│   │   ├── bidEvent.dart
│   │   └── freelancerProfileEvent.dart
│   └── States/
│       ├── projectState.dart
│       ├── bidState.dart
│       └── freelancerProfileState.dart
└── View/
    ├── ClientScreens/
    │   ├── ClientDashboard.dart
    │   ├── PostProject.dart
    │   ├── ViewBids.dart
    │   └── ClientProfile.dart
    └── FreelancerDashboard/
        ├── FreelancerDashboard.dart
        ├── ProjectDetails.dart
        ├── BidSubmissionPage.dart
        ├── MyApplicationsPage.dart
        ├── FreelancerProfile.dart
        └── EditProfile.dart
```

---

## 📅 Daily Progress

### 🔐 Authentication
- Firebase Auth integration with login and registration flows
- Role-based routing (Client / Freelancer) on successful login
- Auth state persistence across app restarts

---

### 📋 Project Management — Client Side
- `ProjectModel` with Firestore `toMap` / `fromMap` including `Timestamp` handling
- `ProjectRepository` with `createProject` and `streamProjects` (real-time Firestore stream)
- `ProjectBloc` with `CreateProjectRequested` and `LoadProjectsRequested` events using `emit.forEach` for live updates
- Fixed stream cancellation bug — removed `emit(ProjectLoading())` from create handler to prevent killing the active stream
- `PostProjectScreen` — full form with title, description, category, budget, duration, price type, and preferences
- `ClientDashboardPage` — real-time project list with status badges, budget, duration, edit and delete action buttons
- `BlocConsumer` added to dashboard to restart Firestore stream automatically after project creation
- Composite Firestore index created for `clientId + createdAt` query

---

### 🧑‍💻 Project Discovery — Freelancer Side
- `streamAllProjects()` in repository — queries only `Open` status projects ordered by `createdAt` descending
- `LoadAllProjectsRequested` event and `AllProjectsLoadSuccess` state added to `ProjectBloc`
- `FreelancerDashboard` — live project feed replacing static hardcoded cards
- `JobCard` widget displaying title, category, description preview, budget, date, and duration
- Composite Firestore index created for `status + createdAt` query
- `ProjectDetailsPage` — accepts real `ProjectModel`, displays full project info with status badge and formatted date

---

### 💼 Bid / Proposal System
- `BidModel` with fields: `bidId`, `projectId`, `projectTitle`, `freelancerId`, `freelancerName`, `bidAmount`, `estimatedDuration`, `coverLetter`, `status`, `createdAt`
- `BidRepository` with:
  - `submitBid` — creates bid document in Firestore
  - `streamBidsForProject` — real-time bids stream for client
  - `streamMyBids` — real-time stream of freelancer's own bids
  - `acceptBid` — batch operation: accepts selected bid, rejects all others, updates project status to `In Progress`
  - `withdrawBid` — updates bid status to `withdrawn`
  - `updateBidStatus` — generic status updater for `under_review` / `shortlisted`
- `BidBloc` with events: `SubmitBidRequested`, `LoadBidsForProject`, `LoadMyBids`, `AcceptBidRequested`, `WithdrawBidRequested`, `FilterApplicationsByStatus`, `SearchApplications`
- `BidSubmissionPage` — freelancer submits bid amount, estimated duration, and cover letter
- `ViewBidsPage` (Client) — dynamic list of all proposals per project with freelancer avatar, bid amount, duration, cover letter preview, status badge, hire confirmation dialog, and chat button
- Composite Firestore indexes created for `projectId + createdAt` and `freelancerId + createdAt`

---

### 📂 My Applications — Freelancer Side
- `MyApplicationsPage` — real-time applications list for the logged-in freelancer
- Status filter tabs: All, Applied, Under Review, Shortlisted, Hired, Rejected — with live counts per tab
- Search bar filtering applications by project title
- Pull-to-refresh support
- `ApplicationCard` showing project title, applied date, bid amount, progress bar, step indicators (Applied → Review → Shortlisted → Hired), and status badge
- Withdraw button visible only for `pending` applications — with confirmation dialog
- Message Client button visible for `accepted` applications
- Empty state UI when no applications exist for selected filter

---

### 👤 Freelancer Profile System
- `FreelancerModel` with fields: name, title, location, about, profileImageUrl, responseTime, skills (with percentage), portfolio (with image), rating, totalReviews, totalProjects, totalEarnings
- `SkillModel` and `PortfolioItem` nested models with `toMap` / `fromMap`
- `FreelancerRepository` with:
  - `streamProfile` — real-time Firestore profile stream
  - `saveProfile` — creates or merges profile document
  - `uploadProfileImage` — uploads to Firebase Storage at `profile_images/{uid}.jpg`
  - `uploadPortfolioImage` — uploads to Firebase Storage at `portfolio_images/{uid}/{timestamp}.jpg`
- `FreelancerProfileBloc` with events: `LoadFreelancerProfile`, `UpdateFreelancerProfile`, `UploadProfileImage`, `UploadPortfolioImage`, `RemovePortfolioItem`
- `ProfileScreen` — fully dynamic with real-time data:
  - Profile image upload via gallery picker with upload progress overlay
  - Stats row: total projects, earnings, rating, reviews
  - About section
  - Skills with animated linear progress bars
  - Portfolio grid with image upload, title, description, and delete button
  - Ratings breakdown with star distribution bars
- `EditProfileScreen` — editable form for name, title, location, about, response time, and dynamic skill list with add/remove
- Profile image reflected live in `FreelancerDashboard` AppBar and bottom navigation Profile tab using `BlocBuilder`
- `cached_network_image` used throughout for efficient image loading and caching

---

## 🔥 Firebase Collections

| Collection | Purpose |
|---|---|
| `projects` | All client-posted projects |
| `bids` | All freelancer proposals |
| `freelancers` | Freelancer profile data |

### Firestore Composite Indexes
| Collection | Fields |
|---|---|
| `projects` | `clientId` ↑, `createdAt` ↓ |
| `projects` | `status` ↑, `createdAt` ↓ |
| `bids` | `projectId` ↑, `createdAt` ↓ |
| `bids` | `freelancerId` ↑, `createdAt` ↓ |

---

## 🚀 Features Overview

### Client
- ✅ Post projects with full details
- ✅ View all submitted bids per project
- ✅ Move bids through review pipeline (Under Review → Shortlisted → Hired)
- ✅ Hire a freelancer with one tap — auto-rejects other bids and updates project status

### Freelancer
- ✅ Browse all open projects in real time
- ✅ View full project details and submit proposals
- ✅ Track all applications with status pipeline and progress bar
- ✅ Filter and search applications by status or title
- ✅ Withdraw pending applications
- ✅ Dynamic profile with image upload, skills, and portfolio

---

## 🚧 In Progress

- Client Profile — dynamic with Firestore integration
- Notifications — real-time backend with Firestore instead of static UI
- Earnings screen — freelancer earnings history and summary

---

## 📌 Upcoming

- 💬 Chat / Messaging system between client and freelancer
- 📄 Contracts screen — active project contracts and milestones
- ⭐ Rating & Review system — post project completion
- 🔔 Push notifications via FCM
- 🛡️ Admin panel — manage users, projects, and disputes

---

## 📸 Screenshots

> _Coming soon_

---

## 🧑‍💻 Author

**Your Name**
Flutter Developer | Firebase | BLoC
[GitHub](https://github.com/kishan-ghulekar) • [LinkedIn](https://www.linkedin.com/in/kishan-ghulekar1)
