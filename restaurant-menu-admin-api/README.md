# Restaurant Menu Admin API

**Spring Boot Git-Backed Admin API for Bapu Ki Kutia Digital Menu**

This is a Spring Boot backend service that provides REST API endpoints for managing restaurant menu data. When admins make changes via the API, the service automatically commits and pushes changes to the GitHub repository, triggering GitHub Actions deployment.

---

## 🏗️ Architecture

```
Admin UI → Spring Boot REST API → Edit menu-data.json → Git Commit & Push → GitHub → GitHub Pages Auto-Deploy
```

### Key Features
- ✅ **Git Version Control** - Every menu change is tracked as a Git commit
- ✅ **JWT Authentication** - Secure admin access with Spring Security
- ✅ **RESTful API** - CRUD operations for categories and dishes
- ✅ **Automated Deployment** - Changes trigger GitHub Actions workflow
- ✅ **No Frontend Changes** - Static site remains unchanged

---

## 🚀 Quick Start (15 minutes)

### Prerequisites Check

```bash
# Check Java (need 21+)
java -version

# Check Maven (need 3.6+)
mvn -version

# Check Node.js (for admin UI)
node --version
npm --version
```

### Step 1: Configure GitHub Token (5 min)

1. Generate token at: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Check scope: `repo` (full control)
4. Copy the token

Create `src/main/resources/application-local.yml`:

```yaml
github:
  repository:
    token: YOUR_GITHUB_TOKEN_HERE

jwt:
  secret: your-super-secret-jwt-key-at-least-32-characters-long

admin:
  username: admin
  password: admin123
  email: admin@example.com
```

**Important:** This file is in `.gitignore` and won't be committed.

### Step 2: Start Backend (3 min)

```bash
# Build and run
mvn clean install -DskipTests
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

Wait for: `Started MenuAdminApplication in X.XXX seconds`

The API will start on `http://localhost:8080`

### Step 3: Test Backend (2 min)

```bash
# Login to get JWT token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Expected: JWT token in response

### Step 4: Start Frontend (5 min)

```bash
cd admin-ui
npm install        # First time only
npm run dev        # Start dev server
```

Open: http://localhost:3000 and login with `admin`/`admin123`

### Running in IntelliJ IDEA

See [INTELLIJ_SETUP.md](INTELLIJ_SETUP.md) for IDE setup instructions.

---

## 🔐 Authentication

### Login

```bash
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "your-password"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "username": "admin",
  "email": "admin@bapukikutia.com"
}
```

### Using the Token

Include the token in all subsequent requests:

```bash
Authorization: Bearer <your-token>
```

---

## 📚 API Endpoints

### Menu

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/menu` | Get complete menu data |

### Categories

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/categories` | Get all categories | ✅ |
| GET | `/api/categories/{id}` | Get category by ID | ✅ |
| POST | `/api/categories` | Create new category | ✅ |
| PUT | `/api/categories/{id}` | Update category | ✅ |
| DELETE | `/api/categories/{id}` | Delete category | ✅ |

### Dishes

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/categories/{categoryId}/dishes` | Get dishes in category | ✅ |
| GET | `/api/categories/{categoryId}/dishes/{dishId}` | Get dish by ID | ✅ |
| POST | `/api/categories/{categoryId}/dishes` | Create new dish | ✅ |
| PUT | `/api/categories/{categoryId}/dishes/{dishId}` | Update dish | ✅ |
| DELETE | `/api/categories/{categoryId}/dishes/{dishId}` | Delete dish | ✅ |
| PATCH | `/api/categories/{categoryId}/dishes/{dishId}/availability` | Toggle availability | ✅ |
| PATCH | `/api/categories/{categoryId}/dishes/{dishId}/price` | Update price | ✅ |

---

## 📝 Example Usage

### Create a New Dish

```bash
POST /api/categories/starters/dishes
Authorization: Bearer <token>
Content-Type: application/json

{
  "id": "spring-rolls",
  "name": "Spring Rolls",
  "price": 180,
  "image": "static/images/dishes/spring-rolls.jpg",
  "alt_text": "Spring Rolls",
  "description": "Crispy vegetable spring rolls with sweet chili sauce",
  "available": true,
  "categoryId": "starters",
  "is_vegetarian": true,
  "is_vegan": false,
  "is_spicy": false,
  "tags": ["crispy", "popular"]
}
```

### Update Dish Price

```bash
PATCH /api/categories/starters/dishes/spring-rolls/price
Authorization: Bearer <token>
Content-Type: application/json

{
  "price": 199
}
```

**Git Commit:** Automatically creates commit: `Update Spring Rolls price: ₹180 → ₹199`

### Toggle Dish Availability

```bash
PATCH /api/categories/starters/dishes/spring-rolls/availability
Authorization: Bearer <token>
```

**Git Commit:** Automatically creates commit: `Mark dish unavailable: Spring Rolls`

---

## ⚙️ Configuration

### application.yml

Key configuration properties:

```yaml
server:
  port: 8080

github:
  repository:
    url: https://github.com/ShubhamChouksey123/restaurant-menu.git
    branch: main
    username: ShubhamChouksey123
    token: ${GITHUB_TOKEN}
  menu:
    file-path: static/data/menu-data.json
  local:
    clone-directory: ${user.home}/.restaurant-menu-repo

jwt:
  secret: ${JWT_SECRET}
  expiration: 86400000 # 24 hours

admin:
  username: ${ADMIN_USERNAME:admin}
  password: ${ADMIN_PASSWORD}
  email: ${ADMIN_EMAIL:admin@bapukikutia.com}

cors:
  allowed-origins: http://localhost:3000,http://localhost:5173
```

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Spring Boot | 3.2.0 | Backend framework |
| JGit | 6.7.0 | Java Git implementation |
| Spring Security | 3.2.0 | Authentication & authorization |
| JWT (jjwt) | 0.12.3 | Token-based authentication |
| Jackson | 2.15.0 | JSON processing |
| Maven | 3.6+ | Build tool |
| Java | 21 (OpenJDK 21.0.4 LTS) | Programming language |

---

## 🔒 Security

### GitHub Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with `repo` scope
3. Copy token and set as environment variable or in `application-local.yml`
4. **Never commit the token to Git!**

### JWT Secret

Generate a secure random string (minimum 32 characters):

```bash
openssl rand -base64 32
```

---

## 🚢 Deployment

### Deploy to OCI (Oracle Cloud Infrastructure)

1. **Create OCI Compute Instance**
2. **Install Java 21 (OpenJDK 21.0.4 LTS)**
3. **Build JAR**:
   ```bash
   mvn clean package -DskipTests
   ```
4. **Upload JAR to server**
5. **Set environment variables** on server
6. **Run as service**:
   ```bash
   java -jar restaurant-menu-admin-api-1.0.0.jar
   ```

### Environment Variables for Production

```bash
export GITHUB_TOKEN=your-pat-token
export JWT_SECRET=your-jwt-secret
export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=secure-password
export SPRING_PROFILES_ACTIVE=prod
```

---

## 🧪 Testing

### Run Tests

```bash
mvn test
```

### Manual API Testing with cURL

```bash
# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Get all categories (use token from login)
curl -X GET http://localhost:8080/api/categories \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📊 Project Structure

```
restaurant-menu-admin-api/
├── src/main/java/com/bapukikutia/menuadmin/
│   ├── config/          # Configuration classes (Security, Git, CORS)
│   ├── controller/      # REST Controllers (Auth, Menu, Category, Dish)
│   ├── dto/             # Data Transfer Objects (Auth, Price)
│   ├── exception/       # Custom exceptions and global handler
│   ├── model/           # Domain models (User, Category, Dish, MenuData)
│   ├── security/        # JWT utilities and authentication filter
│   ├── service/         # Business logic (GitService, MenuService, UserService)
│   └── MenuAdminApplication.java
├── src/main/resources/
│   └── application.yml  # Main configuration
├── src/test/java/       # Unit and integration tests
├── pom.xml              # Maven dependencies
└── README.md            # This file
```

---

## 🎯 Workflow Example

**User updates dish price via API:**

1. Admin calls `PATCH /api/categories/paneer/dishes/paneer-tikka/price` with `{"price": 299}`
2. MenuService updates `menu-data.json` in memory
3. GitService writes updated JSON to local repo file
4. JGit creates commit: `"Update Paneer Tikka price: ₹289 → ₹299"`
5. JGit pushes commit to GitHub `main` branch
6. GitHub Actions workflow triggers automatically
7. Site rebuilds and deploys to GitHub Pages
8. Changes visible on live site in 1-2 minutes

---

## 🐛 Troubleshooting

### Git Clone Fails
- Check GitHub PAT has `repo` permissions
- Verify repository URL is correct
- Ensure network connectivity to GitHub

### JWT Token Expired
- Token expires after 24 hours by default
- Login again to get new token

### CORS Errors
- Check `cors.allowed-origins` includes your frontend URL
- Verify frontend sends `Authorization` header correctly

---

## 📖 Additional Resources

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [JGit User Guide](https://wiki.eclipse.org/JGit/User_Guide)
- [JWT.io](https://jwt.io/) - JWT debugger
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

---

## 👨‍💻 Author

**Shubham Chouksey**
- GitHub: [@ShubhamChouksey123](https://github.com/ShubhamChouksey123)
- Email: shubhamchouksey1998@gmail.com

---

## 📝 License

MIT License - See parent project LICENSE file

**Version:** 1.0.0
**Status:** 🚀 Ready for Development
