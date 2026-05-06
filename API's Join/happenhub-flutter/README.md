# HappenHub Flutter App 📱

Local event discovery app — Flutter frontend for the HappenHub Spring Boot API.

---

## 🗂 Project Structure

```
lib/
├── main.dart                          ← Entry point + SplashScreen + auto-login
├── models/
│   ├── event_model.dart               ← EventModel (matches backend EventResponse)
│   ├── saved_event_model.dart         ← SavedEventModel
│   └── user_model.dart                ← UserModel (matches AuthResponse)
├── services/
│   ├── auth_service.dart              ← register, login, logout, token storage
│   ├── event_service.dart             ← CRUD + search + filter
│   └── saved_event_service.dart       ← bookmark management
├── screens/
│   ├── main_nav.dart                  ← Bottom tab navigator
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── events/
│   │   ├── home_screen.dart           ← Discovery + search + filters
│   │   ├── event_detail_screen.dart   ← Full event view + save button
│   │   └── create_event_screen.dart   ← Form for BUSINESS users
│   ├── saved/
│   │   └── saved_events_screen.dart   ← Bookmarked events list
│   └── profile/
│       └── profile_screen.dart        ← User info + logout
├── widgets/
│   ├── event_card.dart                ← Rich event card with category strip
│   ├── common_widgets.dart            ← Shimmer loader, ErrorView, EmptyView
│   └── app_text_field.dart            ← Styled input field
└── utils/
    ├── constants.dart                 ← API URLs, storage keys, categories/moods
    └── app_theme.dart                 ← Dark theme with Playfair Display + DM Sans
```

---

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK 3.x
- Android Studio / Xcode
- Running HappenHub backend (see backend README)

### 1. Install dependencies
```bash
cd happenhub-flutter
flutter pub get
```

### 2. Configure API URL
Edit `lib/utils/constants.dart`:

```dart
// Android emulator (default)
static const String baseUrl = 'http://10.0.2.2:8080/api';

// iOS simulator
static const String baseUrl = 'http://localhost:8080/api';

// Physical device (find your machine's LAN IP)
static const String baseUrl = 'http://192.168.x.x:8080/api';
```

### 3. Run
```bash
flutter run
```

---

## 🎨 Design

| Aspect | Choice |
|--------|--------|
| Theme | Dark (deep navy + coral-red + amber) |
| Display font | Playfair Display |
| Body font | DM Sans |
| Primary color | `#E94560` (coral-red) |
| Accent | `#FFB347` (warm amber) |

---

## 📱 Screens & Features

### Splash Screen
- Animated logo with fade + scale
- Auto-login: checks stored JWT, skips login if valid

### Home (Discover)
- Live event feed from API
- **Search bar** with 300ms debounce
- **Category chips** (Music, Food, Sports, Tech, Art…)
- **Mood chips** (fun 🎉, chill 😌, productive 💪…)
- **Upcoming** button — filters to future events only
- Pull-to-refresh, shimmer loading, empty/error states
- Heart button on each card to save/unsave instantly

### Event Detail
- Hero header with category emoji
- Date, time, location, organiser info rows
- Full description
- Animated heart save button

### Create Event (Business only)
- Title, description, location fields
- Category & mood dropdowns
- Native date/time pickers
- POST to backend with creator ID

### Saved Events
- All bookmarked events
- Swipe-to-delete (Dismissible)
- Pull-to-refresh

### Profile
- Avatar with initials
- Role badge (User / Business)
- Business users see "Create Event" shortcut
- Logout with confirmation dialog

---

## 🔐 Auth Flow

```
App start
  → Check SharedPreferences for token
  → Token found? → MainNav (home)
  → No token?   → LoginScreen

Login/Register
  → POST /api/auth/login
  → Store token + user info in SharedPreferences
  → Navigate to MainNav

Protected API calls
  → Read token from SharedPreferences
  → Set Authorization: Bearer <token> header

Logout
  → Clear SharedPreferences
  → Navigate to LoginScreen
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `http` | REST API calls |
| `shared_preferences` | Persist JWT + user info |
| `google_fonts` | Playfair Display & DM Sans |
| `shimmer` | Loading skeleton animation |
| `intl` | Date formatting |
