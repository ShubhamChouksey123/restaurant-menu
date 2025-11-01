# IntelliJ IDEA Setup Guide for Restaurant Menu Admin API

Complete guide for running the Restaurant Menu Admin API in IntelliJ IDEA.

---

## 🚀 Quick Run (3 Steps)

### Step 1: Open Project
```
File → Open → Select "restaurant-menu-admin-api" folder → Open
```

### Step 2: Update Environment Variables
1. Run → Edit Configurations → MenuAdminApplication
2. Environment Variables → Update `GITHUB_TOKEN`
3. Generate token at: https://github.com/settings/tokens (requires `repo` scope)

### Step 3: Run Application
Select **MenuAdminApplication** from dropdown → Click Run ▶️

---

## 📋 Prerequisites

Before you begin:

✅ Java 21+ (OpenJDK 21.0.4 LTS or Corretto)
✅ Maven 3.6+
✅ IntelliJ IDEA (Community or Ultimate)
✅ GitHub Personal Access Token with `repo` scope

**Check your installation:**
```bash
java -version   # Should show 21+
mvn -version    # Should show 3.6+
```

---

## 📂 Step 1: Open Project in IntelliJ

1. Open IntelliJ IDEA
2. Click **File → Open**
3. Navigate to the `restaurant-menu-admin-api` directory
4. Click **Open**
5. Wait for Maven import (IntelliJ will automatically detect `pom.xml`)

**If dependencies don't import:**
- Right-click `pom.xml` → Maven → Reload Project

---

## ⚙️ Step 2: Configure Environment Variables

### Option A: Using IntelliJ Run Configuration (Recommended)

The run configuration file `.run/MenuAdminApplication.run.xml` has been created with default values. You need to update the environment variables:

1. In IntelliJ, go to **Run → Edit Configurations**
2. Select **MenuAdminApplication**
3. Find **Environment Variables** section
4. Update the following values:

```
GITHUB_USERNAME=ShubhamChouksey123
GITHUB_TOKEN=<your-github-personal-access-token>
JWT_SECRET=<generate-a-secure-32-char-secret>
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

### Option B: Using .env File (Alternative)

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and fill in real values

3. Install IntelliJ EnvFile plugin:
   - **Settings → Plugins → Search "EnvFile" → Install**
   - Restart IntelliJ
   - Go to **Run → Edit Configurations**
   - Enable EnvFile and point to `.env` file

---

## Step 3: Generate GitHub Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click **Generate new token (classic)**
3. Token name: `Restaurant Menu Admin API`
4. Select scopes:
   - ✅ **repo** (full control of private repositories)
5. Click **Generate token**
6. **IMPORTANT:** Copy the token immediately (it won't be shown again)
7. Update `GITHUB_TOKEN` in your run configuration

---

## 🔨 Step 4: Build Project (Optional)

IntelliJ imports Maven dependencies automatically. To manually rebuild:

**Option A: Using Maven Run Configuration**
1. Run → Edit Configurations
2. Select **Maven Clean Install**
3. Click Run

**Option B: Using Maven Tool Window**
1. View → Tool Windows → Maven
2. Lifecycle → clean → install

**Option C: Using Terminal**
```bash
mvn clean install -DskipTests
```

---

## ▶️ Step 5: Run the Application

### Option A: Using Run Configuration (Easiest)

1. In IntelliJ toolbar, select **MenuAdminApplication** from the dropdown
2. Click the green **Run** button (▶️) or press `Ctrl+R` (Mac) / `Shift+F10` (Windows)

### Option B: Using Main Class

1. Open `MenuAdminApplication.java`
2. Click the green play button (▶️) next to the `main` method
3. Select **Run 'MenuAdminApplication.main()'**

### Option C: Using Terminal

```bash
cd restaurant-menu-admin-api
./mvnw-java21.sh spring-boot:run
```

---

## ✅ Step 6: Verify Application Started

Look for these success indicators in the console:

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.0)

✅ Started MenuAdminApplication in X.XXX seconds
✅ Tomcat started on port(s): 8080 (http)
```

**If you see errors:**
- Verify GitHub token is valid (not expired)
- Check environment variables are set correctly
- Ensure port 8080 is not in use: `lsof -ti:8080 | xargs kill -9`

---

## 🧪 Step 7: Test API Endpoints

### 1. Health Check
Open browser: http://localhost:8080/actuator/health

### 2. Login (Get JWT Token)
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "type": "Bearer",
  "username": "admin",
  "email": "admin@bapukikutia.com"
}
```

### 3. Get Menu (Requires JWT Token)
```bash
curl http://localhost:8080/api/menu \
  -H "Authorization: Bearer <token-from-login>"
```

---

## 🎨 Step 8: Run React Admin UI (Optional)

If you want to test the full system:

1. Open a new terminal
2. Navigate to admin UI:
   ```bash
   cd restaurant-menu-admin-api/admin-ui
   ```

3. Install dependencies (first time only):
   ```bash
   npm install
   ```

4. Start dev server:
   ```bash
   npm run dev
   ```

5. Open browser: http://localhost:5173
6. Login with: `admin` / `admin123`

---

## 🔧 Troubleshooting

### Port 8080 Already in Use

**Problem:** `Port 8080 is already in use`

**Solution 1:** Kill process on port 8080
```bash
lsof -ti:8080 | xargs kill -9
```

**Solution 2:** Change port in `application.yml`
```yaml
server:
  port: 8081
```

### GitHub Authentication Failed

**Problem:** `Authentication to GitHub failed` or `Invalid credentials`

**Solutions:**
1. Verify token in Run Configuration (Edit Configurations → Environment Variables)
2. Check token has `repo` scope: https://github.com/settings/tokens
3. Test token manually:
   ```bash
   curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
   ```
4. Token may have expired - generate new one

### Cannot Resolve Dependencies

**Problem:** Dependencies not downloading or IntelliJ shows errors

**Solutions:**
1. Right-click `pom.xml` → Maven → Reload Project
2. Force update: `mvn clean install -U`
3. Invalidate caches: File → Invalidate Caches → Invalidate and Restart

### Java Version Mismatch

**Problem:** `Unsupported class file major version` or Java version errors

**Solution:**
1. File → Project Structure → Project
2. Set **SDK** to Java 21 (Corretto or OpenJDK)
3. Set **Language Level** to 21
4. Apply changes and rebuild

### Lombok Not Working

**Problem:** `Cannot resolve symbol` for @Data, @Getter, etc.

**Solutions:**
1. Install Lombok plugin: Settings → Plugins → Search "Lombok" → Install
2. Enable annotation processing:
   - Settings → Build, Execution, Deployment → Compiler → Annotation Processors
   - Check **Enable annotation processing**
3. Restart IntelliJ

### IntelliJ Not Finding Main Class

**Problem:** Cannot find `MenuAdminApplication` main class

**Solution:** Right-click `pom.xml` → Maven → Reload Project

---

## 📁 Project Structure

```
restaurant-menu-admin-api/
├── .run/
│   ├── MenuAdminApplication.run.xml     ← IntelliJ run config
│   └── Maven Clean Install.run.xml      ← Maven build config
├── src/main/java/
│   └── com/bapukikutia/menuadmin/
│       ├── MenuAdminApplication.java    ← Main class
│       ├── controller/                  ← REST endpoints
│       ├── service/                     ← Business logic
│       ├── model/                       ← Data models
│       ├── config/                      ← Configuration
│       └── security/                    ← JWT & Security
├── src/main/resources/
│   └── application.yml                  ← Configuration
├── admin-ui/                            ← React admin dashboard
├── pom.xml                              ← Maven dependencies
└── .env.example                         ← Environment template
```

---

## 📚 Additional Information

### Run Configuration Details

The `.run/MenuAdminApplication.run.xml` file contains:
- Main class: `com.bapukikutia.menuadmin.MenuAdminApplication`
- Module: `restaurant-menu-admin-api`
- Pre-configured environment variables
- Active profile: `local`

### What Happens on Startup

1. Spring Boot application initializes
2. Spring Security configures JWT authentication
3. Git service clones/pulls repository to `~/.restaurant-menu-repo`
4. REST controllers register endpoints
5. Tomcat server starts on port 8080
6. Application ready for requests

### Architecture Flow

```
React Admin UI (Port 5173/3000)
         ↓ HTTP/REST + JWT
Spring Boot API (Port 8080)
         ↓ JGit Operations
Git Repository (menu-data.json)
         ↓ Git Push
GitHub → GitHub Actions → GitHub Pages
```

---

## 🎯 Next Steps

After successfully running:

1. ✅ Test all API endpoints with cURL
2. ✅ Run React admin UI and test full workflow
3. ✅ Update dish price and verify Git commit
4. 🔐 Change default admin password for production
5. 🔑 Generate strong JWT secret (32+ characters)
6. 🚀 Deploy to production (see [SETUP_GUIDE.md](SETUP_GUIDE.md))

---

## 📖 Further Reading

- **Complete Setup Guide:** [SETUP_GUIDE.md](SETUP_GUIDE.md) - Production deployment
- **API Documentation:** [README.md](README.md) - Full API reference
- **Spring Boot Docs:** https://spring.io/projects/spring-boot
- **JGit Documentation:** https://www.eclipse.org/jgit/

---

**Ready to run!** 🚀

Open IntelliJ → Select **MenuAdminApplication** → Click **Run** ▶️
