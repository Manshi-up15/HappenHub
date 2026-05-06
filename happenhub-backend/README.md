# HappenHub Backend 🎉

Local event discovery platform — Spring Boot REST API with JWT authentication.

---

## 🗂 Project Structure

```
src/main/java/com/happenhub/
├── HappenHubApplication.java       ← Entry point
├── config/
│   └── SecurityConfig.java         ← Spring Security + CORS + JWT filter
├── controller/
│   ├── AuthController.java          ← POST /api/auth/register, /login
│   ├── EventController.java         ← GET/POST/PUT/DELETE /api/events
│   └── SavedEventController.java    ← POST/GET/DELETE /api/saved
├── dto/
│   ├── ApiResponse.java             ← Generic response wrapper
│   ├── AuthResponse.java            ← Login/register response
│   ├── EventRequest.java            ← Create/update event body
│   ├── EventResponse.java           ← Event output
│   ├── LoginRequest.java
│   ├── RegisterRequest.java
│   ├── SaveEventRequest.java
│   └── SavedEventResponse.java
├── exception/
│   ├── GlobalExceptionHandler.java  ← @RestControllerAdvice
│   ├── ResourceNotFoundException.java
│   └── DuplicateResourceException.java
├── model/
│   ├── User.java                    ← users table
│   ├── Event.java                   ← events table
│   └── SavedEvent.java              ← saved_events table
├── repository/
│   ├── UserRepository.java
│   ├── EventRepository.java         ← Custom filter + search queries
│   └── SavedEventRepository.java
├── security/
│   ├── JwtUtils.java                ← Token generation & validation
│   ├── JwtAuthFilter.java           ← Intercepts every request
│   └── UserDetailsServiceImpl.java
└── service/
    ├── AuthService.java
    ├── EventService.java
    └── SavedEventService.java
```

---

## ⚙️ Setup

### Prerequisites
- Java 17+
- Maven 3.8+
- MySQL 8.x running locally

### 1. Create the database
```sql
CREATE DATABASE happenhub_db;
```

### 2. Configure credentials
Edit `src/main/resources/application.properties`:
```properties
spring.datasource.username=root
spring.datasource.password=YOUR_PASSWORD
app.jwt.secret=CHANGE_THIS_TO_A_LONG_RANDOM_SECRET_KEY
```

### 3. Run
```bash
mvn spring-boot:run
```
Tables are auto-created by Hibernate (`ddl-auto=update`).

---

## 🔌 API Reference

### Auth (public)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register (returns JWT) |
| POST | `/api/auth/login` | Login (returns JWT) |

**Register body:**
```json
{
  "name": "Alice",
  "email": "alice@example.com",
  "password": "secret123",
  "role": "BUSINESS"
}
```

**Login body:**
```json
{ "email": "alice@example.com", "password": "secret123" }
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGci...",
    "type": "Bearer",
    "userId": 1,
    "name": "Alice",
    "email": "alice@example.com",
    "role": "BUSINESS"
  }
}
```

---

### Events
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/events` | No | All events (optional filters) |
| GET | `/api/events/{id}` | No | Single event |
| GET | `/api/events/search?keyword=music` | No | Full-text search |
| GET | `/api/events/upcoming` | No | Future events |
| POST | `/api/events?createdById=1` | BUSINESS | Create event |
| PUT | `/api/events/{id}` | Yes | Update event |
| DELETE | `/api/events/{id}` | Yes | Delete event |

**Filter events:**
```
GET /api/events?category=Music&mood=fun&from=2025-06-01&to=2025-06-30
```

**Create event body:**
```json
{
  "title": "Jazz Night",
  "description": "Live jazz at the waterfront",
  "category": "Music",
  "mood": "chill",
  "location": "Marina Bay, Chennai",
  "date": "2025-06-15",
  "time": "19:00:00"
}
```

---

### Saved Events (all require JWT)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/saved` | Bookmark an event |
| GET | `/api/saved/{userId}` | User's bookmarks |
| DELETE | `/api/saved/{id}` | Remove bookmark |

---

## 🔐 Using the JWT

Include the token in every protected request:
```
Authorization: Bearer eyJhbGci...
```

---

## 🗄️ Database Schema

Hibernate auto-generates these tables on startup:

```sql
users          (id, name, email, password, role)
events         (id, title, description, category, mood, location, date, time, created_at, created_by)
saved_events   (id, user_id, event_id, saved_at)
```
