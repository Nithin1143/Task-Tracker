# 🚀 Quick Execution Guide - Python 3.11 + Node 25.8

## Your Exact Setup
```
Python: 3.11.x
Node:   25.8.x  
npm:    10.8.x
```

**All tools are compatible. No conflicts. Ready to deploy.** ✅

---

## ⏱️ Total Time: 30-35 Minutes

| Phase | Time | Status |
|-------|------|--------|
| Pre-check | 2 min | Automatic |
| Azure setup | 18 min | Automatic |
| Manual Azure AD | 5 min | **You do this** |
| Frontend build | 3 min | Automatic (npm) |
| Frontend deploy | 5 min | Automatic (Azure CLI) |
| Testing | 2 min | **You verify** |

---

## 📋 Copy-Paste Execution Steps

### Step 1: Pre-Deployment Check (2 minutes)
Open PowerShell in your project directory and run:

```powershell
# Navigate to project
cd c:\Users\srisa\Downloads\t_tracker

# Run validation
.\pre-deploy-check.ps1

# Expected output: All ✓ green checks
# If any ✗ red: Fix before proceeding
```

### Step 2: Login to Azure (1 minute)
```powershell
# Login (only needed once per machine)
az login

# Verify
az account show
```

### Step 3: Deploy Everything (18 minutes)
```powershell
# Run main deployment
.\deploy-to-azure.ps1

# This creates:
# ✓ Resource group
# ✓ PostgreSQL database (Python 3.11 compatible)
# ✓ App Service (Python 3.11 runtime)
# ✓ Static Web App
# ✓ Environment variables for Node 25.8 frontend

# Script will pause for manual step
```

### Step 4: Manual Azure AD Configuration (5 minutes)
The script will display:
```
⚠️  MANUAL STEP REQUIRED

Copy this URL:
https://<your-frontend-name>.azurestaticapps.net/

Go to: https://portal.azure.com
→ Search: "App registrations"
→ Select app: 0842ec45-61b4-405c-8a1f-f5c8d1b2329a
→ Click: "Authentication" in left menu
→ Click: "Add a platform" → "Web"
→ Paste: The URL from above (with trailing /)
→ Click: "Save"

Return here and press ENTER to continue...
```

**Exact steps:**
1. Copy URL from script output
2. Open https://portal.azure.com in browser
3. Search for "app registrations"
4. Find app with Client ID: `0842ec45-61b4-405c-8a1f-f5c8d1b2329a`
5. Click it
6. Click "Authentication" (left menu)
7. Click "Add a platform" → "Web"
8. Paste the URL in "Redirect URI" field
9. Click "Save"
10. Return to PowerShell
11. Press ENTER

### Step 5: Build & Deploy Frontend (8 minutes)
```powershell
# Navigate to frontend
cd frontend

# Install dependencies (Node 25.8)
npm install
# Takes ~2 minutes

# Build with Vite (Node 25.8)
npm run build
# Takes ~1 minute
# Expected: ✓ built in X.XXs

# Go back to root
cd ..

# Deploy frontend to Static Web App
# (Script output will show the exact app name)
az staticwebapp upload `
  --name task-tracker-app-XXXX `
  --source "./frontend/dist" `
  --resource-group task-tracker-rg

# Expected: Deployment successful
```

### Step 6: Verify Everything Works (3 minutes)

**Backend Health Check:**
```powershell
# Get the exact URL from script output (will look like)
$backendUrl = "https://task-tracker-api-1234.azurewebsites.net"

# Test health endpoint
curl.exe -i "$backendUrl/health"

# Expected response:
# HTTP/1.1 200 OK
# {"status":"ok"}
```

**Test Frontend:**
```powershell
# Get frontend URL from script output
# Open in browser:
https://task-tracker-app-XXXX.azurestaticapps.net

# You should see:
# ✓ Login page loads
# ✓ "Login with Azure AD" button visible
```

**Test End-to-End:**
1. Click "Login with Azure AD"
2. Sign in with your Azure account
3. You should be redirected to dashboard
4. Dashboard should show your name
5. Try creating a test project (if allowed)

---

## 🎯 Expected Success Outputs

### ✅ Backend Running
```
Status: 200 OK
Response: {"status":"ok"}
URL: https://task-tracker-api-XXXX.azurewebsites.net
```

### ✅ Frontend Loaded
```
URL: https://task-tracker-app-XXXX.azurestaticapps.net
Displays: Login page with Azure AD button
No errors in browser console
```

### ✅ Database Connected
```
Backend logs show: "Database schema checked/created successfully"
Can see tables in Azure Portal PostgreSQL
```

### ✅ Full Login Cycle
```
1. Click login button
2. Redirected to Microsoft
3. Authenticate
4. Redirected back to dashboard
5. Dashboard displays user info
```

---

## 🔧 Required Variable Changes in Script

**The `deploy-to-azure.ps1` script has these variables you can customize:**

```powershell
# Line 21: Database password (CHANGE THIS to something secure)
$dbPassword = "YourSecurePassword@123"  # ← Change this!

# Line 12: Location (change if needed)
$location = "eastus"  # Options: eastus2, westeurope, southeastasia, etc.

# Line 36: App Service tier (B1=cheap, S1=fast production)
--sku B1  # Change to S1 for better performance
```

**That's it.** Everything else is pre-configured for Python 3.11 + Node 25.8.

---

## 🚨 Critical: What NOT to Change

✅ DO NOT change:
- Line 45: `--runtime "PYTHON:3.11"` (correct for your Python)
- Lines 18-20: Database names (correct as is)
- Lines 26-28: Azure AD IDs (your app config)

---

## 📊 Architecture Deployed

```
┌─────────────────────────────────────────┐
│        Your Local Machine               │
│  ├─ Python 3.11  ✓ Used locally         │
│  ├─ Node 25.8    ✓ Build frontend     │
│  └─ Azure CLI    ✓ Deploy to cloud    │
└─────────────────────────────────────────┘
                ↓
        Deploy to Azure
                ↓
┌─────────────────────────────────────────┐
│     Task Tracker on Azure Cloud         │
│                                         │
│  Frontend (Node 25.8 built)            │
│  └─ Static Web Apps (CDN)              │
│     └─ URL: azurestaticapps.net        │
│                                         │
│  Backend (Python 3.11)                 │
│  └─ App Service + Uvicorn              │
│     └─ URL: azurewebsites.net          │
│                                         │
│  Database (PostgreSQL)                 │
│  └─ Azure Database for PostgreSQL      │
│     └─ task_tracker DB                 │
│                                         │
│  Auth (Azure AD)                       │
│  └─ MSAL integration                   │
│     └─ Single Sign-On                  │
└─────────────────────────────────────────┘
```

---

## 💾 Save These URLs After Deployment

After the script completes, you'll get URLs like:

```
Backend API:  https://task-tracker-api-1234.azurewebsites.net
Frontend:     https://task-tracker-app-5678.azurestaticapps.net
Database:     task-tracker-db-server-9999.postgres.database.azure.com
```

**Save these!** You'll need them for:
- Testing
- Sharing with team
- Monitoring
- Debugging

---

## 🚨 If Something Goes Wrong

### ❌ "Python 3.11 not found"
```powershell
# Check
python --version

# Fix: Download from https://www.python.org/downloads/
# Make sure "Add Python to PATH" is checked during install
```

### ❌ "Node 25.8 not detected"
```powershell
# Check
node --version

# Fix: Download from https://nodejs.org/
# Node 25.8 is LTS/current as of March 2026
```

### ❌ "npm install fails"
```powershell
# Clear cache
npm cache clean --force

# Reinstall
npm install

# If still fails, check:
npm list
```

### ❌ "Az staticwebapp upload fails"
```powershell
# Verify dist folder was created
ls frontend/dist

# If empty, rebuild
npm run build

# Then try upload again
```

### ❌ "Backend health check fails"
```powershell
# Check if app is running
az webapp show --resource-group task-tracker-rg --name task-tracker-api-XXXX --query state

# Restart if needed
az webapp restart --resource-group task-tracker-rg --name task-tracker-api-XXXX

# Wait 30 seconds and try health check again
```

---

## 📞 Get Help Fast

**Check these in order:**
1. `DETAILED_DEPLOYMENT_PLAN.md` - Comprehensive guide
2. `AZURE_COMMANDS_REFERENCE.md` - CLI command help
3. Backend logs: `az webapp log tail -g task-tracker-rg -n task-tracker-api-XXXX`
4. Azure Portal error messages

---

## ✅ Pre-Execution Checklist

- [ ] Python 3.11 installed: `python --version` shows 3.11.x
- [ ] Node 25.8 installed: `node --version` shows v25.8.x
- [ ] npm installed: `npm --version` shows 10.x
- [ ] Git clean: `git status` shows no changes
- [ ] Azure CLI installed: `az --version` works
- [ ] Logged into Azure: `az account show` works
- [ ] All files committed
- [ ] Pre-check passes: `.\pre-deploy-check.ps1`

Once all checked ✅, run: `.\deploy-to-azure.ps1`

---

## 🎉 After Successful Deployment

Your application will be:
- ✅ Live on the internet
- ✅ Using your Azure domain
- ✅ Connected to PostgreSQL database
- ✅ With Azure AD authentication
- ✅ Accessible 24/7
- ✅ Auto-scaling ready
- ✅ Daily backups

Next optional steps:
- Add custom domain
- Set up CI/CD
- Enable monitoring
- Configure alerts

---

**Ready?** → Run `.\pre-deploy-check.ps1` now!
