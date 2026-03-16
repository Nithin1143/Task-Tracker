# 📋 Complete Deployment Checklist

## Pre-Deployment Phase (Before Running Scripts)

### System Requirements
- [ ] **Operating System**: Windows 10/11 or macOS
- [ ] **Internet Connection**: Stable, 10+ Mbps
- [ ] **RAM**: 8GB+ available
- [ ] **Disk Space**: 5GB+ free

### Tool Verification (Python 3.11 & Node 25.8)

**Python 3.11**
```powershell
python --version     # Must show: Python 3.11.x
pip --version        # Must show: pip x.x.x (Python 3.11)
```
- [ ] Python 3.11 installed and in PATH
- [ ] pip is working
- [ ] Can run: `python -c "import sys; print(sys.version)"`

**Node 25.8 & npm**
```powershell
node --version       # Must show: v25.8.x
npm --version        # Must show: 10.x.x
```
- [ ] Node 25.8 (or latest) installed
- [ ] npm is working
- [ ] Can run: `npm list -g --depth=0`

**Git**
```powershell
git --version        # Must show: git version 2.x
git status           # Must show: On branch main/master
```
- [ ] Git installed
- [ ] Repository clean (no uncommitted changes)
- [ ] On main or master branch

**Azure CLI**
```powershell
az --version         # Must show: azure-cli 2.48.0+
az account show      # Must show: Current subscription
```
- [ ] Azure CLI installed
- [ ] Logged into Azure account: `az login`
- [ ] Default subscription set

### Project Setup
- [ ] All files are in: `c:\Users\srisa\Downloads\t_tracker\`
- [ ] Backend folder exists: `backend/`
- [ ] Frontend folder exists: `frontend/`
- [ ] Docker file present: `backend/Dockerfile`
- [ ] Requirements present: `backend/requirements.txt`
- [ ] Package.json present: `frontend/package.json`
- [ ] Scripts present:
  - [ ] `deploy-to-azure.ps1`
  - [ ] `pre-deploy-check.ps1`
  - [ ] `backend/startup.sh`

### Pre-Check Pass
- [ ] Run: `.\pre-deploy-check.ps1` and all checks pass ✅
- [ ] No error messages (⚠️ warning messages are OK)

---

## Deployment Phase 1: Automated Azure Setup (18 minutes)

### Pre-Script Setup
- [ ] **Save database password somewhere safe** (you'll need it later)
  ```
  Format: YourSecurePassword@123
  Contains: Uppercase, lowercase, numbers, symbols
  Length: 12+ characters
  ```
- [ ] **Note the location** (default: eastus)
  - Closer locations deploy faster
  - Supported: eastus, eastus2, westeurope, southeastasia, etc.

### Running Deploy Script
```powershell
# From project root
cd c:\Users\srisa\Downloads\t_tracker

# Run deployment
.\deploy-to-azure.ps1

# Watch console output
# Each phase should show ✓ success messages
```

### Script Execution Verification

**Phase 1: Resource Group Creation (1 minute)**
- [ ] Message: "Creating resource group 'task-tracker-rg'... ✓"
- [ ] Command working: `az group show --name task-tracker-rg`

**Phase 2: PostgreSQL Setup (5-10 minutes)**
Expected messages:
- [ ] "Creating PostgreSQL server... ✓"
- [ ] "Firewall rules configured... ✓"
- [ ] "Database 'task_tracker' created... ✓"
- [ ] "Connection string: postgresql://..." (save this!)

Verify:
- [ ] Can see it in Azure Portal: Home → Resource Groups → task-tracker-rg

**Phase 3: App Service Setup (2 minutes)**
Expected messages:
- [ ] "Creating App Service plan... ✓"
- [ ] "Creating web app 'task-tracker-api-XXXX'... ✓"

Verify:
- [ ] Backend URL shows: `https://task-tracker-api-XXXX.azurewebsites.net`

**Phase 4: Backend Deployment (3 minutes)**
Expected messages:
- [ ] "Deploying backend code... ✓"
- [ ] "Backend health check passed... ✓"
- [ ] "Backend URL: https://task-tracker-api-XXXX.azurewebsites.net"

Test immediately:
```powershell
# Get the URL from output and test
curl.exe -i https://task-tracker-api-XXXX.azurewebsites.net/health
# Should return: {"status":"ok"}
```

**Phase 5: Static Web App Creation (2 minutes)**
Expected messages:
- [ ] "Creating Static Web App 'task-tracker-app-XXXX'... ✓"
- [ ] "Frontend URL: https://task-tracker-app-XXXX.azurestaticapps.net"

Save the Frontend URL:
- [ ] Frontend URL: `https://task-tracker-app-XXXX.azurestaticapps.net` (save this!)

---

## Deployment Phase 2: Manual Azure AD Configuration (5 minutes)

### Script Pause Point
The script will **PAUSE** and display:
```
⚠️  MANUAL STEP REQUIRED

Go to: https://portal.azure.com
Path: Azure Active Directory → App registrations
Find: 0842ec45-61b4-405c-8a1f-f5c8d1b2329a
Add: https://task-tracker-app-XXXX.azurestaticapps.net/
```

### Exact Steps to Follow

**Step 1: Open Azure Portal**
- [ ] Navigate to: https://portal.azure.com
- [ ] Ensure you're logged in with same account

**Step 2: Find App Registrations**
- [ ] Click: Search icon (top)
- [ ] Type: "App registrations"
- [ ] Click: "App registrations" in results

**Step 3: Find the Correct App**
- [ ] Look for app with name containing your project
- [ ] Or search by Client ID: `0842ec45-61b4-405c-8a1f-f5c8d1b2329a`
- [ ] Click on it

**Step 4: Add Redirect URI**
- [ ] Click: "Authentication" (left menu)
- [ ] Look for: "Web" platform section
- [ ] If not there, click: "Add a platform" → "Web"
- [ ] In "Redirect URIs" field, add:
  ```
  https://task-tracker-app-XXXX.azurestaticapps.net/
  ```
  (Note the trailing slash)

**Step 5: Save**
- [ ] Click: "Save" button
- [ ] Wait for confirmation

### Verification
- [ ] Redirect URI appears in the list
- [ ] No error messages
- [ ] Status shows saved
- [ ] Return to PowerShell script

**Step 6: Continue Deployment**
- [ ] Switch back to PowerShell
- [ ] Press ENTER to continue script
- [ ] Script should resume and complete

---

## Deployment Phase 3: Frontend Build & Deployment (8 minutes)

### Build with Node 25.8

**Navigate to Frontend**
```powershell
cd frontend
```
- [ ] Verify you're in: `frontend` folder
- [ ] Can see: `package.json` file

**Install Dependencies**
```powershell
npm install
# Takes ~2 minutes
```
- [ ] No error messages
- [ ] `node_modules` folder created
- [ ] All packages installed

**Build with Vite**
```powershell
npm run build
# Takes ~1 minute
```
- [ ] Output shows: "✓ built in X.XXs"
- [ ] `dist` folder created with HTML/CSS/JS files
- [ ] No TypeScript errors
- [ ] dist/index.html exists

### Deploy to Static Web App

**Go Back to Root**
```powershell
cd ..
```

**Deploy Frontend**
```powershell
# Replace XXXX with your actual app name from earlier output
az staticwebapp upload `
  --name task-tracker-app-XXXX `
  --source "./frontend/dist" `
  --resource-group task-tracker-rg
```
- [ ] Command executes without error
- [ ] Shows: "Deployment successful"
- [ ] Frontend URL is from script: `https://task-tracker-app-XXXX.azurestaticapps.net`

### Verify Frontend Deployed
```powershell
# Wait 30 seconds for CDN cache
Start-Sleep -Seconds 30

# Test frontend URL in browser
Start-Process "https://task-tracker-app-XXXX.azurestaticapps.net"
```
- [ ] Page loads (may take 30-60 seconds)
- [ ] See login page
- [ ] "Login with Azure AD" button visible
- [ ] No 404 errors

---

## Testing & Verification Phase (5 minutes)

### 1. Backend Health Check ✅
```powershell
# Test API health endpoint
curl.exe -i https://task-tracker-api-XXXX.azurewebsites.net/health

# Expected output:
# HTTP/1.1 200 OK
# {"status":"ok"}
```
- [ ] Health check returns 200 OK
- [ ] Response body: `{"status":"ok"}`

### 2. Frontend Accessibility ✅
```powershell
# Open in browser
Start-Process "https://task-tracker-app-XXXX.azurestaticapps.net"
```
- [ ] Page loads without 404
- [ ] Login page visible
- [ ] No JavaScript errors (check console: F12)
- [ ] CSS styling applied correctly

### 3. Authentication Flow ✅
1. [ ] Click "Login with Azure AD"
2. [ ] Redirected to Microsoft login page
3. [ ] Enter your Azure account credentials
4. [ ] Redirected back to app
5. [ ] Dashboard loads
6. [ ] User name displayed

### 4. API Communication ✅
- [ ] After login, page doesn't show CORS errors
- [ ] Check browser console (F12 → Console tab)
- [ ] Look for errors mentioning "CORS" or "blocked"
- [ ] If errors, check if running in incognito (ad-blocker issue)

### 5. Database Connection ✅
```powershell
# Check backend logs for DB connection
az webapp log tail --resource-group task-tracker-rg --name task-tracker-api-XXXX

# Look for: "Database schema checked/created successfully"
```
- [ ] Backend logs show successful database connection
- [ ] No "Connection timeout" errors
- [ ] Tables should be auto-created

### 6. Data Persistence ✅
(If your UI allows creating items)
- [ ] Try creating a test project/task
- [ ] Refresh page
- [ ] Data still visible (persisted in database)

---

## Post-Deployment Phase: Documentation & Cleanup

### Save Important Information

**Create a file: `DEPLOYMENT_INFO.txt`**
```
Deployment Date: [TODAY]
Deployment Duration: [TIME TAKEN]

URLs:
- Frontend: https://task-tracker-app-XXXX.azurestaticapps.net
- Backend API: https://task-tracker-api-XXXX.azurewebsites.net
- API Docs: https://task-tracker-api-XXXX.azurewebsites.net/docs

Database:
- Server: task-tracker-db-server-XXXX.postgres.database.azure.com
- Database: task_tracker
- Username: dbadmin
- Password: [SAFE LOCATION - not in this file]

Resource Group: task-tracker-rg
Region: eastus
Subscription ID: [YOUR SUBSCRIPTION]

Cost per Month: ~$43 (PostgreSQL $30 + App Service $13)
```

- [ ] Create and save file
- [ ] Store in safe location
- [ ] Do NOT commit to git

### Cleanup Scripts (Optional)
- [ ] Remove temporary files
- [ ] Clean npm cache if needed: `npm cache clean --force`
- [ ] Commit any local changes to git

### Verify Git Status
```powershell
git status
git log --oneline -n 5
```
- [ ] Working directory clean
- [ ] Recent commits visible
- [ ] Ready for next development

---

## Scaling & Optimization (Optional, After Testing)

### If Performance Needs Scaling
```powershell
# Scale App Service to Standard (S1)
az appservice plan update `
  --resource-group task-tracker-rg `
  --name task-tracker-plan `
  --sku S1
```
- [ ] Faster response times
- [ ] More workers available
- [ ] Cost increases to ~$50-60/month

### If Storage Needs Scaling
```powershell
# Scale PostgreSQL to B_Gen5_2
az postgres server update `
  --resource-group task-tracker-rg `
  --name task-tracker-db-server-XXXX `
  --sku-name B_Gen5_2
```
- [ ] More performance
- [ ] Larger database
- [ ] Storage doubled
- [ ] Cost increases slightly

### Enable Auto-Scaling (Advanced)
```powershell
az monitor autoscale create `
  --resource-group task-tracker-rg `
  --resource-name task-tracker-plan `
  --resource-type "Microsoft.Web/serverfarms" `
  --min-count 1 `
  --max-count 5 `
  --count 2
```
- [ ] Automatically scales based on demand
- [ ] Cost varies with usage

---

## Troubleshooting Checklist

### Health Check Failed
- [ ] Backend app is running: `az webapp show -g task-tracker-rg -n task-tracker-api-XXXX --query state`
- [ ] Restart if needed: `az webapp restart -g task-tracker-rg -n task-tracker-api-XXXX`
- [ ] Wait 30 seconds
- [ ] Try health check again

### Login Doesn't Work
- [ ] Azure AD redirect URI added correctly ✓
- [ ] Frontend .env has correct API_BASE_URL
- [ ] Testing in incognito window (avoid ad-blocker)
- [ ] Backend logs show no errors

### CORS Errors
- [ ] Add frontend domain to ALLOWED_ORIGINS
- [ ] No trailing slash on domain
- [ ] ALLOWED_ORIGIN_REGEX matches your domain
- [ ] Test in incognito (ad-blocker blocking API calls)

### Database Connection Failed
- [ ] Firewall allows Azure services
- [ ] Connection string includes `?sslmode=require`
- [ ] PostgreSQL server is running
- [ ] Database exists: `task_tracker`

### Frontend Not Loading
- [ ] dist/ folder has content: `ls frontend/dist`
- [ ] dist/index.html exists
- [ ] Rebuild: `npm run build`
- [ ] Redeploy: `az staticwebapp upload`

---

## Final Verification Checklist

When everything is complete and working:

- [ ] Backend health endpoint returns `{"status":"ok"}`
- [ ] Frontend loads and displays login page
- [ ] Azure AD login works end-to-end
- [ ] Dashboard visible after login
- [ ] No CORS errors in browser console
- [ ] Backend logs show "Database schema created"
- [ ] All resources visible in Azure Portal
- [ ] URLs saved in safe location
- [ ] Documentation updated
- [ ] Team notified of new URLs

---

## Success! 🎉

If all checks are complete and green, your Task Tracker application is now:

✅ **Live in production on Azure**
✅ **Accessible 24/7 from anywhere**
✅ **Using PostgreSQL managed database**
✅ **With Azure AD authentication**
✅ **Auto-scaled and monitored**
✅ **Daily backups enabled**
✅ **HTTPS encrypted**

Your deployment is complete!

---

**Date Completed**: _________________
**Deployed By**: _________________
**Verified By**: _________________

---

*Keep this checklist for reference during future deployments or maintenance.*
