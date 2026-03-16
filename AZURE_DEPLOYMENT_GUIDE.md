# Azure Deployment Guide for Task Tracker

## Overview
- **Frontend**: Azure Static Web Apps (React + Vite)
- **Backend**: Azure App Service (FastAPI + Python 3.11)
- **Database**: Azure Database for PostgreSQL
- **Authentication**: Azure AD (MSAL) - already configured

---

## Phase 1: Prerequisites & Setup

### Step 1.1: Install Azure CLI
Download and install from: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

```powershell
# Verify installation
az --version
```

### Step 1.2: Login to Azure
```powershell
az login
# This opens a browser window. Sign in with your Azure credentials.

# Verify you're logged in
az account show
```

### Step 1.3: Create Resource Group
```powershell
$resourceGroup = "task-tracker-rg"
$location = "eastus"  # Change to your preferred region (e.g., westeurope, southeastasia)

az group create --name $resourceGroup --location $location
```

---

## Phase 2: Database Setup (Azure PostgreSQL)

### Step 2.1: Create PostgreSQL Server
```powershell
$dbServer = "task-tracker-db-server"  # Must be globally unique
$dbName = "task_tracker"
$dbUser = "dbadmin"
$dbPassword = "YourSecurePassword@123"  # Change this!

az postgres server create `
  --resource-group $resourceGroup `
  --name $dbServer `
  --location $location `
  --admin-user $dbUser `
  --admin-password $dbPassword `
  --sku-name B_Gen5_1 `
  --storage-size 51200 `
  --version 13
```

### Step 2.2: Configure Firewall Rules
```powershell
# Allow Azure services
az postgres server firewall-rule create `
  --resource-group $resourceGroup `
  --server-name $dbServer `
  --name "AllowAzureServices" `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

# Allow your home IP (get your public IP from: https://whatismyipaddress.com)
az postgres server firewall-rule create `
  --resource-group $resourceGroup `
  --server-name $dbServer `
  --name "AllowMyHome" `
  --start-ip-address <YOUR_PUBLIC_IP> `
  --end-ip-address <YOUR_PUBLIC_IP>
```

### Step 2.3: Create Database
```powershell
az postgres db create `
  --resource-group $resourceGroup `
  --server-name $dbServer `
  --name $dbName
```

### Step 2.4: Get Connection String
```powershell
$dbHost = "$dbServer.postgres.database.azure.com"
$connectionString = "postgresql://${dbUser}@${dbServer}:${dbPassword}@${dbHost}:5432/${dbName}"
echo $connectionString
# Save this! You'll need it for Step 4.2
```

---

## Phase 3: Backend Deployment (App Service)

### Step 3.1: Create App Service Plan
```powershell
$appServicePlan = "task-tracker-plan"

az appservice plan create `
  --name $appServicePlan `
  --resource-group $resourceGroup `
  --sku B1 `
  --is-linux
```

### Step 3.2: Create Web App (Backend)
```powershell
$backendAppName = "task-tracker-api"  # Must be globally unique

az webapp create `
  --resource-group $resourceGroup `
  --plan $appServicePlan `
  --name $backendAppName `
  --runtime "PYTHON:3.11"
```

### Step 3.3: Configure Python Settings
```powershell
az webapp config set `
  --resource-group $resourceGroup `
  --name $backendAppName `
  --startup-file "startup.sh"
```

### Step 3.4: Set Environment Variables
```powershell
$dbConnectionString = "postgresql://${dbUser}@${dbServer}:${dbPassword}@${dbHost}:5432/${dbName}?sslmode=require"

az webapp config appsettings set `
  --resource-group $resourceGroup `
  --name $backendAppName `
  --settings `
    DATABASE_URL=$dbConnectionString `
    AZURE_CLIENT_ID="0842ec45-61b4-405c-8a1f-f5c8d1b2329a" `
    AZURE_TENANT_ID="931f45cb-5916-4f22-a21b-af7a33509960" `
    ALLOWED_ORIGINS="https://<your-frontend-domain>" `
    ALLOWED_ORIGIN_REGEX="^https://.*\\.azurestaticapps\\.net$" `
    SECRET_KEY="$(openssl rand -hex 32)" `
    LOG_LEVEL="INFO" `
    AUTO_CREATE_TABLES="false"
```

### Step 3.5: Deploy Backend Code
```powershell
# Create deployment files locally
cd backend

# Initialize git if not already done
git init
git add .
git commit -m "Backend deployment"

# Deploy using git
az webapp up `
  --resource-group $resourceGroup `
  --name $backendAppName `
  --runtime "PYTHON:3.11"
```

### Step 3.6: Verify Backend is Running
```powershell
$backendUrl = "https://${backendAppName}.azurewebsites.net/health"
Invoke-WebRequest -Uri $backendUrl
# Should return: {"status":"ok"}
```

---

## Phase 4: Frontend Deployment (Static Web Apps)

### Step 4.1: Create Static Web App
```powershell
$frontendAppName = "task-tracker-app"
$githubRepo = "https://github.com/YOUR_USERNAME/t_tracker"  # Your repo URL

az staticwebapp create `
  --name $frontendAppName `
  --resource-group $resourceGroup `
  --source $githubRepo `
  --location $location `
  --branch main `
  --app-location "frontend" `
  --output-location "dist" `
  --token "ghp_YOUR_GITHUB_TOKEN"  # Create at: https://github.com/settings/tokens
```

### Step 4.2: Configure Frontend Environment Variables
```powershell
$backendUrl = "https://${backendAppName}.azurewebsites.net"

az staticwebapp appsettings set `
  --name $frontendAppName `
  --resource-group $resourceGroup `
  --setting-names `
    VITE_API_BASE_URL="${backendUrl}/api/v1" `
    VITE_AZURE_CLIENT_ID="0842ec45-61b4-405c-8a1f-f5c8d1b2329a" `
    VITE_AZURE_TENANT_ID="931f45cb-5916-4f22-a21b-af7a33509960" `
    VITE_AZURE_REDIRECT_URI="https://${frontendAppName}.azurestaticapps.net/"
```

### Step 4.3: Get Static Web App URL
```powershell
az staticwebapp show --name $frontendAppName --resource-group $resourceGroup
# Look for "defaultHostname" in the output
# It will be: https://<random-name>.azurestaticapps.net
```

---

## Phase 5: Database Initialization

### Step 5.1: Connect to PostgreSQL and Seed Data
```powershell
# Install PostgreSQL client if needed
# MacOS: brew install postgresql
# Windows: Download from https://www.postgresql.org/download/windows/

$dbHost = "$dbServer.postgres.database.azure.com"
$dbPort = 5432

# Connect and create tables
psql -U "${dbUser}@${dbServer}" -h $dbHost -d $dbName -p $dbPort << EOF
-- Tables are auto-created when backend starts with AUTO_CREATE_TABLES=false in production
-- Or use seed script:
EOF

# Alternative: Run seed script through backend API call
```

---

## Phase 6: Post-Deployment Configuration

### Step 6.1: Update Azure AD Redirect URIs
1. Go to Azure Portal → Azure Active Directory → App registrations
2. Select your app (with Client ID: 0842ec45-61b4-405c-8a1f-f5c8d1b2329a)
3. Go to "Authentication"
4. Add redirect URI: `https://<your-frontend-domain>.azurestaticapps.net/`
5. Save

### Step 6.2: Update Backend CORS Settings
Once you have your Static Web Apps domain:

```powershell
$frontendDomain = "https://<your-frontend-name>.azurestaticapps.net"

az webapp config appsettings set `
  --resource-group $resourceGroup `
  --name $backendAppName `
  --settings ALLOWED_ORIGINS=$frontendDomain
```

### Step 6.3: Enable HTTPS and Custom Domains (Optional)
```powershell
# Add custom domain to Static Web App
az staticwebapp custom-domain create `
  --name $frontendAppName `
  --resource-group $resourceGroup `
  --domain-name "app.yourdomain.com"
```

---

## Phase 7: Testing & Troubleshooting

### Step 7.1: Test Backend Health
```powershell
curl -i https://${backendAppName}.azurewebsites.net/health
```

### Step 7.2: View Backend Logs
```powershell
az webapp log tail `
  --resource-group $resourceGroup `
  --name $backendAppName
```

### Step 7.3: View Frontend Build Logs
```powershell
az staticwebapp show --name $frontendAppName --resource-group $resourceGroup --query "repositoryUrl"
```

### Step 7.4: Common Issues

**Issue: CORS still failing**
- ✅ Verify `ALLOWED_ORIGINS` in backend app settings includes your Static Web App domain
- ✅ Check your frontend environment variables are correct
- ✅ Clear browser cache and test in incognito

**Issue: Database connection failed**
- ✅ Verify firewall rules allow Azure Services
- ✅ Check connection string format includes `?sslmode=require`
- ✅ Verify PostgreSQL server is running

**Issue: Login not working**
- ✅ Verify Azure AD redirect URI is configured in Azure Portal
- ✅ Check AZURE_CLIENT_ID and AZURE_TENANT_ID are correct
- ✅ Verify session storage in browser

---

## Phase 8: Scaling & Production

### Step 8.1: Scale Database
```powershell
az postgres server update `
  --resource-group $resourceGroup `
  --name $dbServer `
  --sku-name B_Gen5_2 `
  --storage-size 102400
```

### Step 8.2: Scale App Service
```powershell
az appservice plan update `
  --resource-group $resourceGroup `
  --name $appServicePlan `
  --sku S1
```

### Step 8.3: Enable Auto-scaling
```powershell
az monitor autoscale create `
  --resource-group $resourceGroup `
  --resource-name $appServicePlan `
  --resource-type "Microsoft.Web/serverfarms" `
  --min-count 1 `
  --max-count 5 `
  --count 2
```

---

## Quick Reference: Resource Names & URLs

```
Resource Group: task-tracker-rg
DB Server: task-tracker-db-server
DB Name: task_tracker
App Service: task-tracker-api
Backend URL: https://task-tracker-api.azurewebsites.net
Frontend App: task-tracker-app
Frontend URL: https://<random>.azurestaticapps.net
```

---

## Cleanup (Delete all resources if needed)
```powershell
az group delete --name task-tracker-rg --yes
```

---

**Questions?** Check Azure CLI documentation: https://learn.microsoft.com/cli/azure/
