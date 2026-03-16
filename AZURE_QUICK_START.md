# Quick Start: Deploy to Azure in 5 Steps

## Total Time: ~20-30 minutes

---

## ✓ Prerequisites
- Azure subscription (free tier available at https://azure.microsoft.com/free)
- Azure CLI installed (https://learn.microsoft.com/cli/azure/install-azure-cli)
- Git installed
- Node.js 16+ (for frontend build)
- Python 3.11 installed locally (optional, for testing)

---

## Step 1: Login to Azure
```powershell
az login
# Verify with:
az account show
```

---

## Step 2: Run Automated Deployment Script
```powershell
cd c:\Users\srisa\Downloads\t_tracker

.\deploy-to-azure.ps1
```

**What this does:**
- Creates PostgreSQL database in Azure
- Creates App Service for FastAPI backend
- Creates Static Web App for React frontend
- Configures all environment variables
- Deploys backend automatically
- Prepares frontend for deployment

---

## Step 3: Update Azure AD Configuration
The script will pause and ask you to:

1. Go to **Azure Portal** → **Azure Active Directory** → **App registrations**
2. Find the app with Client ID: `0842ec45-61b4-405c-8a1f-f5c8d1b2329a`
3. Go to **Authentication** tab
4. Click **"Add a platform"** → **"Web"**
5. Add Redirect URI: `https://<your-frontend-url>.azurestaticapps.net/`
6. Save

---

## Step 4: Deploy Frontend
After the script completes:

```powershell
cd frontend

# Build the app
npm install
npm run build

# Deploy to Static Web App (replace with your app name from script output)
az staticwebapp upload `
  --name task-tracker-app-xyz `
  --source "./dist" `
  --resource-group task-tracker-rg `
  --branch main
```

---

## Step 5: Test the Deployment
1. Go to your frontend URL from script output (e.g., `https://task-tracker-app-xyz.azurestaticapps.net`)
2. You should see the login page
3. Click **"Login with Azure AD"**
4. You should be redirected to dashboard after authentication

---

## 🎉 Success!
Your app is now live on Azure!

**URLs:**
- Frontend: `https://<your-frontend-name>.azurestaticapps.net`
- Backend API: `https://task-tracker-api-xyz.azurewebsites.net`
- API Docs: `https://task-tracker-api-xyz.azurewebsites.net/docs`

---

## Troubleshooting

### ❌ Login not working
1. Check console errors
2. Verify Azure AD redirect URI is configured
3. Make sure `VITE_API_BASE_URL` points to correct backend URL
4. Test in incognito window

### ❌ Backend not responding
```powershell
# Check logs
az webapp log tail --resource-group task-tracker-rg --name task-tracker-api-xyz

# Restart app
az webapp restart --resource-group task-tracker-rg --name task-tracker-api-xyz
```

### ❌ Database connection error
```powershell
# Check firewall rules
az postgres server firewall-rule list --resource-group task-tracker-rg --server-name task-tracker-db-server-xxxx

# Make sure connection string has ?sslmode=require
```

### ❌ Frontend not building
```powershell
cd frontend
npm install --force
npm run build
```

---

## Cost Estimate (USD/month)
- **PostgreSQL (Single Server B1)**: ~$30
- **App Service (B1 Linux)**: ~$13
- **Static Web App**: Free (up to 1GB)
- **Total**: ~$43/month (for small usage)

### To Save Money:
1. Use free tier during development
2. Stop app when not in use: `az webapp stop --resource-group task-tracker-rg --name task-tracker-api-xyz`
3. Use smaller database SKU for testing

---

## Next Steps
- Configure custom domain
- Set up CI/CD with GitHub Actions
- Enable monitoring and alerts
- Scale resources as needed

---

For full documentation, see `AZURE_DEPLOYMENT_GUIDE.md`
