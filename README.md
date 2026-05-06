# 🎉 HappenHub — Event Discovery & Management Platform

HappenHub is a full-stack event discovery and management platform that connects event organizers with attendees. It features mood-based event recommendations, real-time booking, role-based dashboards, and a modern responsive UI.

---

## 📸 Screenshots

| Home Page | Event Details | Organizer Dashboard |
|-----------|---------------|---------------------|
| Browse & search events | View full details & book tickets | Manage events & track revenue |

---

## ✨ Features

### 🔐 Authentication & Authorization
- JWT-based secure authentication
- Role-based access control — **User** and **Organizer** roles
- Separate login flows for users and organizers
- Password encryption using BCrypt

### 🏠 Event Discovery
- Browse all upcoming events on the home page
- **Search** events by title or location
- **Mood-based filtering** — find events by mood (Music 🎵, Sports 🏃, Food 🍕, Art 🎨, etc.)
- Category-based and date-range filtering

### 📋 Event Management (Organizers)
- Create new events with title, description, date, time, location, mood, price, and image
- Edit and update existing event details
- Delete events
- Set custom ticket pricing (₹)
- Organizer dashboard with revenue and event statistics

### 🎟️ Booking System
- Book tickets for any event
- Multiple bookings allowed per user (book the same event more than once)
- Real-time ticket price calculation based on quantity
- Booking history visible in the user dashboard

### 👤 User Dashboard
- View upcoming and past booked events
- Track total events attended and money spent
- Quick access to event details from booking history
- "Your Next Event" highlight section

### 💾 Saved Events
- Bookmark/save events for later
- View all saved events in one place

### 📱 Flutter Mobile App
- Cross-platform mobile app (iOS & Android)
- Full feature parity with the web frontend
- Native mobile experience

---

## 🛠️ Tech Stack

### Backend
| Technology | Purpose |
|------------|---------|
| **Java 17** | Core language |
| **Spring Boot 3.2** | Application framework |
| **Spring Security** | Authentication & authorization |
| **Spring Data JPA** | ORM & database access |
| **Hibernate** | Object-relational mapping |
| **MySQL 8.0** | Relational database |
| **JWT (jjwt 0.11.5)** | Token-based authentication |
| **Lombok** | Boilerplate code reduction |
| **Maven** | Build & dependency management |

### Frontend (Web)
| Technology | Purpose |
|------------|---------|
| **React 18** | UI library |
| **Vite** | Build tool & dev server |
| **React Router v6** | Client-side routing |
| **TailwindCSS** | Utility-first styling |
| **Axios** | HTTP client |
| **Lucide React** | Icon library |

### Mobile
| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |

---

## 📁 Project Structure

```
HappenHub/
├── happenhub-backend/                # Spring Boot Backend
│   ├── src/main/java/com/happenhub/
│   │   ├── config/                   # Security & CORS configuration
│   │   ├── controller/               # REST API controllers
│   │   ├── dto/                      # Data Transfer Objects
│   │   ├── exception/                # Custom exception handlers
│   │   ├── model/                    # JPA Entity models
│   │   ├── repository/               # Spring Data repositories
│   │   ├── security/                 # JWT utilities & filters
│   │   └── service/                  # Business logic layer
│   ├── src/main/resources/
│   │   └── application.properties    # App configuration
│   └── pom.xml
│
├── happenhub-original/               # React Frontend
│   └── happenhub-main/frontend/
│       ├── src/
│       │   ├── components/           # Reusable UI components
│       │   ├── context/              # Auth context provider
│       │   ├── pages/                # Page components
│       │   ├── styles/               # CSS stylesheets
│       │   └── utils/                # API utility & helpers
│       ├── package.json
│       └── vite.config.js
│
├── happenhub-flutter/                # Flutter Mobile App
│   ├── lib/
│   │   ├── models/                   # Data models
│   │   ├── screens/                  # App screens
│   │   ├── services/                 # API services
│   │   ├── utils/                    # Theme & constants
│   │   └── widgets/                  # Reusable widgets
│   └── pubspec.yaml
│
├── .gitignore
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- **Java 17** (JDK) — [Download](https://adoptium.net/)
- **Maven 3.8+** — [Download](https://maven.apache.org/download.cgi)
- **MySQL 8.0** — [Download](https://dev.mysql.com/downloads/)
- **Node.js 18+** — [Download](https://nodejs.org/)
- **npm 9+** (comes with Node.js)
- **Flutter 3.x** (optional, for mobile app) — [Download](https://flutter.dev/docs/get-started/install)

---

### 1️⃣ Database Setup

Open MySQL and create the database (it auto-creates, but you can do it manually):

```sql
CREATE DATABASE IF NOT EXISTS happenhub_db;
```

Update your database credentials in `happenhub-backend/src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/happenhub_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=YOUR_MYSQL_PASSWORD
```

---

### 2️⃣ Backend Setup

```bash
# Navigate to backend directory
cd happenhub-backend

# Install dependencies & run
mvn clean install -DskipTests

# Start the backend server (runs on port 8080)
mvn spring-boot:run
```

The backend API will be available at: **http://localhost:8080**

Hibernate will auto-create all required tables on first run.

---

### 3️⃣ Frontend Setup

```bash
# Navigate to frontend directory
cd happenhub-original/happenhub-main/frontend

# Install dependencies
npm install

# Start the development server (runs on port 5173)
npm run dev
```

The frontend will be available at: **http://localhost:5173**

> **Note:** Make sure the backend is running before starting the frontend.

---

### 4️⃣ Flutter Mobile App (Optional)

```bash
# Navigate to flutter directory
cd happenhub-flutter

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

> Update the API base URL in `lib/utils/constants.dart` to point to your backend server.

---

## 🔗 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/register` | Register a new user |
| `POST` | `/api/auth/login` | Login and receive JWT token |

### Events (Public)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/events` | Get all events (with optional filters) |
| `GET` | `/api/events/{id}` | Get event by ID |
| `GET` | `/api/events/search?keyword=` | Search events by keyword |
| `GET` | `/api/events/upcoming` | Get upcoming events |
| `GET` | `/api/events/creator/{userId}` | Get events by organizer |

### Events (Protected — JWT Required)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/events?createdById={id}` | Create a new event |
| `PUT` | `/api/events/{id}` | Update an event |
| `DELETE` | `/api/events/{id}` | Delete an event |

### Bookings (Protected)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/applied` | Book an event |
| `GET` | `/api/applied/{userId}` | Get user's bookings |
| `DELETE` | `/api/applied/{id}` | Cancel a booking |

### Saved Events (Protected)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/saved` | Save/bookmark an event |
| `GET` | `/api/saved/{userId}` | Get user's saved events |
| `DELETE` | `/api/saved/{id}` | Remove a saved event |

---

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `server.port` | `8080` | Backend server port |
| `spring.datasource.username` | `root` | MySQL username |
| `spring.datasource.password` | — | MySQL password |
| `app.jwt.secret` | — | JWT signing secret key |
| `app.jwt.expiration-ms` | `86400000` | JWT token expiry (24 hours) |

### Frontend Environment

Create a `.env` file in the frontend directory:

```env
VITE_API_BASE_URL=http://localhost:8080/api
```

---

## 🧪 Running Tests

### Backend Tests
```bash
cd happenhub-backend
mvn test
```

### Frontend Lint
```bash
cd happenhub-original/happenhub-main/frontend
npm run lint
```

---

## 📦 Building for Production

### Backend
```bash
cd happenhub-backend
mvn clean package -DskipTests
java -jar target/happenhub-backend-1.0.0.jar
```

### Frontend
```bash
cd happenhub-original/happenhub-main/frontend
npm run build
```

The build output will be in the `dist/` folder, ready to be served by any static file server (Nginx, Apache, etc.).

---

## 🗃️ Database Schema

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│    users      │     │    events     │     │  applied_events  │
├──────────────┤     ├──────────────┤     ├──────────────────┤
│ id (PK)      │────▶│ id (PK)      │◀────│ id (PK)          │
│ name         │     │ title        │     │ user_id (FK)     │
│ email        │     │ description  │     │ event_id (FK)    │
│ password     │     │ category     │     │ applied_at       │
│ role         │     │ mood         │     └──────────────────┘
└──────────────┘     │ location     │
                     │ date         │     ┌──────────────────┐
                     │ time         │     │  saved_events    │
                     │ image_url    │     ├──────────────────┤
                     │ price        │◀────│ id (PK)          │
                     │ created_by   │     │ user_id (FK)     │
                     │ created_at   │     │ event_id (FK)    │
                     └──────────────┘     │ saved_at         │
                                          └──────────────────┘
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**Manshi** — [@Manshi-up15](https://github.com/Manshi-up15)

---

<p align="center">
  Made with ❤️ for the love of events
</p>
