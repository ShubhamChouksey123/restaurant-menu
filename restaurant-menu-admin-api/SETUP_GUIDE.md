# Restaurant Menu Admin API - Complete Setup Guide

This guide will walk you through setting up the Spring Boot Git-backed admin API system from scratch.

---

## 📋 Prerequisites

Before you begin, ensure you have:

- ✅ Java 21 (OpenJDK 21.0.4 LTS) or higher installed
- ✅ Maven 3.6+ installed
- ✅ Node.js 16+ and npm installed (for React UI)
- ✅ GitHub account with repository access
- ✅ Git installed locally

---

## Step 1: Generate GitHub Personal Access Token (PAT)

The backend needs a PAT to commit and push changes to your GitHub repository.

### 1.1 Create PAT on GitHub

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token (classic)"**
3. Configure token:
   - **Note:** `restaurant-menu-admin-api`
   - **Expiration:** 90 days (or longer)
   - **Scopes:** Select `repo` (full control of private repositories)
4. Click **"Generate token"**
5. **IMPORTANT:** Copy the token immediately (you won't see it again!)

Example token format: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### 1.2 Store Token Securely

**⚠️ NEVER commit this token to Git!**

Create file: `src/main/resources/application-local.yml`

```yaml
github:
  repository:
    token: ghp_your_actual_token_here

jwt:
  secret: your-super-secret-jwt-key-at-least-32-characters-long-for-security

admin:
  username: admin
  password: YourSecurePassword123!
  email: your-email@example.com
```

This file is already in `.gitignore` so it won't be committed.

---

## Step 2: Configure Application Settings

### 2.1 Update Main Configuration

Edit `src/main/resources/application.yml`:

```yaml
github:
  repository:
    url: https://github.com/YOUR_USERNAME/restaurant-menu.git  # Your actual repo
    branch: main  # Or your target branch
    username: YOUR_GITHUB_USERNAME
    token: ${GITHUB_TOKEN}  # Will come from env or application-local.yml

  menu:
    file-path: static/data/menu-data.json  # Path within repo

  local:
    clone-directory: ${user.home}/.restaurant-menu-repo  # Local clone location
```

### 2.2 Generate JWT Secret

Generate a secure random secret key:

```bash
# On Mac/Linux
openssl rand -base64 32

# Or use online generator
# https://www.grc.com/passwords.htm
```

Copy the output and use it in `application-local.yml`.

---

## Step 3: Build and Run Backend

### 3.1 Build Project

```bash
cd restaurant-menu-admin-api

# Clean and build
mvn clean install

# If tests fail, you can skip them for now
mvn clean install -DskipTests
```

### 3.2 Run Application

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

**What happens on startup:**
1. Application starts on port 8080
2. Git service initializes
3. Clones repository to `~/.restaurant-menu-repo`
4. Or pulls latest changes if already cloned
5. Admin user is created with credentials from config

### 3.3 Verify Backend is Running

```bash
# Check health
curl http://localhost:8080/api/auth/login

# Should return: {"timestamp":"...","status":400,"error":"Bad Request"...}
# This is expected - means API is running but needs credentials
```

---

## Step 4: Test Authentication

### 4.1 Login via cURL

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"YourSecurePassword123!"}'
```

**Expected response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "username": "admin",
  "email": "your-email@example.com"
}
```

### 4.2 Test Protected Endpoint

```bash
# Save token from previous response
TOKEN="your-token-here"

# Get all categories
curl http://localhost:8080/api/categories \
  -H "Authorization: Bearer $TOKEN"
```

---

## Step 5: Setup React Admin UI

### 5.1 Install Dependencies

```bash
cd admin-ui
npm install
```

### 5.2 Configure API URL (Optional)

Create `.env.local`:

```
VITE_API_URL=http://localhost:8080
```

### 5.3 Start Development Server

```bash
npm run dev
```

Admin UI will be available at: `http://localhost:3000`

### 5.4 Login to UI

1. Open browser to `http://localhost:3000`
2. Enter credentials:
   - Username: `admin`
   - Password: `YourSecurePassword123!`
3. You should see the dashboard with menu data

---

## Step 6: Test End-to-End Workflow

### 6.1 Update Dish Price via UI

1. Navigate to any category in the dashboard
2. Click **"Price"** button on any dish
3. Enter new price (e.g., `299`)
4. Confirm

**What happens:**
1. ✅ API receives PATCH request
2. ✅ MenuService updates JSON in memory
3. ✅ GitService writes updated JSON to local file
4. ✅ JGit creates commit: `"Update Paneer Tikka price: ₹280 → ₹299"`
5. ✅ JGit pushes to GitHub
6. ✅ GitHub Actions workflow triggers
7. ✅ Site rebuilds and deploys to GitHub Pages

### 6.2 Verify Changes on GitHub

1. Go to your GitHub repository
2. Check latest commit - should see your price update commit
3. Check GitHub Actions tab - workflow should be running
4. Wait 1-2 minutes for deployment
5. Visit live site - price should be updated!

### 6.3 Check Local Git Repository

```bash
cd ~/.restaurant-menu-repo
git log -5 --oneline

# Should show recent commits made by the API
```

---

## Step 7: Deploy to Production (OCI)

### 7.1 Build Production JAR

```bash
cd restaurant-menu-admin-api
mvn clean package -DskipTests

# JAR will be at: target/restaurant-menu-admin-api-1.0.0.jar
```

### 7.2 Upload to OCI Server

```bash
# Using scp
scp target/restaurant-menu-admin-api-1.0.0.jar user@your-oci-server:/opt/app/

# Or use FileZilla, WinSCP, etc.
```

### 7.3 Set Environment Variables on Server

SSH into your OCI server:

```bash
ssh user@your-oci-server
```

Create environment file:

```bash
sudo nano /opt/app/.env
```

Add:

```bash
export GITHUB_TOKEN=ghp_your_actual_token
export JWT_SECRET=your-generated-jwt-secret
export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=YourSecurePassword123!
export SPRING_PROFILES_ACTIVE=prod
```

### 7.4 Create Systemd Service

```bash
sudo nano /etc/systemd/system/restaurant-menu-admin.service
```

```ini
[Unit]
Description=Restaurant Menu Admin API
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/app
EnvironmentFile=/opt/app/.env
ExecStart=/usr/bin/java -jar /opt/app/restaurant-menu-admin-api-1.0.0.jar
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 7.5 Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable restaurant-menu-admin.service
sudo systemctl start restaurant-menu-admin.service

# Check status
sudo systemctl status restaurant-menu-admin.service

# View logs
sudo journalctl -u restaurant-menu-admin.service -f
```

### 7.6 Deploy React UI (Static Build)

```bash
# On local machine
cd admin-ui
npm run build

# Upload dist folder to server
scp -r dist/* user@your-oci-server:/var/www/admin-ui/

# Configure nginx to serve static files
```

---

## 🔧 Troubleshooting

### Issue: Git Clone Fails

**Error:** `Failed to clone repository`

**Solution:**
1. Verify GitHub token has `repo` permissions
2. Check repository URL is correct
3. Test token manually:
   ```bash
   curl -H "Authorization: token ghp_yourtoken" https://api.github.com/user
   ```

### Issue: JWT Token Invalid

**Error:** `401 Unauthorized`

**Solution:**
1. Ensure JWT secret is at least 32 characters
2. Token expires after 24 hours - login again
3. Check `Authorization: Bearer TOKEN` header format

### Issue: Changes Not Appearing on Live Site

**Possible causes:**
1. ✅ GitHub Actions workflow failed - check Actions tab
2. ✅ Commit didn't push - check git logs
3. ✅ Browser cache - hard refresh (Ctrl+Shift+R)
4. ✅ GitHub Pages deployment delay - wait 2-3 minutes

**Debug steps:**
```bash
# Check local repo
cd ~/.restaurant-menu-repo
git log -1  # Should show your latest commit
git status  # Should be clean

# Check GitHub
# Visit: https://github.com/YOUR_USERNAME/restaurant-menu/commits/main
```

### Issue: Port 8080 Already in Use

**Error:** `Port 8080 is already in use`

**Solution:**
```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 PID

# Or change port in application.yml
server:
  port: 8081
```

### Issue: Permission Denied on Git Operations

**Error:** `Permission denied (publickey)`

**Solution:**
1. Use HTTPS URL, not SSH
2. Ensure token is correctly set in config
3. Verify token hasn't expired

---

## 📊 Monitoring & Logs

### Backend Logs

```bash
# Development
# Logs appear in console where mvn spring-boot:run is running

# Production (systemd)
sudo journalctl -u restaurant-menu-admin.service -f
```

### Git Operations Log

```bash
# Check what API committed
cd ~/.restaurant-menu-repo
git log --oneline -10
```

### GitHub Actions

1. Go to repository → Actions tab
2. View workflow runs
3. Check deployment status

---

## 🎯 Next Steps

Once everything is working:

1. ✅ Change default admin password
2. ✅ Set up proper JWT secret (not default)
3. ✅ Configure production CORS origins
4. ✅ Set up SSL/HTTPS for production
5. ✅ Add more admin users if needed
6. ✅ Implement full CRUD for dishes (create/edit forms)
7. ✅ Add image upload functionality
8. ✅ Set up monitoring and alerts

---

You now have a fully functional Git-backed admin system that automatically deploys menu changes to GitHub Pages!
