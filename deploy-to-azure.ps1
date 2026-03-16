# ============================================================================
# Azure Deployment Script for Task Tracker Application
# ============================================================================
# This script automates the deployment of Task Tracker to Azure
# Usage: .\deploy-to-azure.ps1
# ============================================================================

param(
    [string]$ResourceGroup = "task-tracker-rg",
    [string]$Location = "eastus",
    [string]$Environment = "production"
)

# ─── Configuration Variables ───────────────────────────────────────────────
$dbServer = "task-tracker-db-server-$((Get-Random -Minimum 1000 -Maximum 9999))"
$dbName = "task_tracker"
$dbUser = "dbadmin"
$dbPassword = "P@ssw0rd$((Get-Random -Minimum 100000 -Maximum 999999))"
$appServicePlan = "task-tracker-plan"
$backendAppName = "task-tracker-api-$((Get-Random -Minimum 100 -Maximum 999))"
$frontendAppName = "task-tracker-app-$((Get-Random -Minimum 100 -Maximum 999))"
$azureClientId = "0842ec45-61b4-405c-8a1f-f5c8d1b2329a"
$azureTenantId = "931f45cb-5916-4f22-a21b-af7a33509960"

# ─── Color Output Helper ───────────────────────────────────────────────────
function Write-Status {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor Cyan
}

# ============================================================================
# Phase 1: Verify Prerequisites
# ============================================================================
Write-Info "Verifying prerequisites..."

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Azure CLI not found. Install from: https://aka.ms/cli"
    exit 1
}
Write-Status "Azure CLI is installed"

# Check if logged in
try {
    $account = az account show 2>$null | ConvertFrom-Json
    Write-Status "Logged in as: $($account.user.name)"
} catch {
    Write-Error-Custom "Not logged in to Azure. Run: az login"
    exit 1
}

# ============================================================================
# Phase 2: Create Resource Group
# ============================================================================
Write-Info "Creating resource group..."
az group create --name $ResourceGroup --location $Location | Out-Null
Write-Status "Resource group '$ResourceGroup' created/verified"

# ============================================================================
# Phase 3: Create PostgreSQL Server
# ============================================================================
Write-Info "Creating PostgreSQL server (this may take 5-10 minutes)..."
az postgres server create `
    --resource-group $ResourceGroup `
    --name $dbServer `
    --location $Location `
    --admin-user $dbUser `
    --admin-password $dbPassword `
    --sku-name B_Gen5_1 `
    --storage-size 51200 `
    --version 13 `
    --output none
Write-Status "PostgreSQL server '$dbServer' created"

# Configure firewall
Write-Info "Configuring firewall rules..."
az postgres server firewall-rule create `
    --resource-group $ResourceGroup `
    --server-name $dbServer `
    --name "AllowAzureServices" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 `
    --output none
Write-Status "Firewall rule created for Azure Services"

# Create database
Write-Info "Creating database..."
az postgres db create `
    --resource-group $ResourceGroup `
    --server-name $dbServer `
    --name $dbName `
    --output none
Write-Status "Database '$dbName' created"

# Build connection string
$dbHost = "$dbServer.postgres.database.azure.com"
$connectionString = "postgresql://${dbUser}@${dbServer}:${dbPassword}@${dbHost}:5432/${dbName}?sslmode=require"
Write-Status "PostgreSQL connection string ready"

# ============================================================================
# Phase 4: Create App Service Plan and Backend App
# ============================================================================
Write-Info "Creating App Service plan..."
az appservice plan create `
    --name $appServicePlan `
    --resource-group $ResourceGroup `
    --sku B1 `
    --is-linux `
    --output none
Write-Status "App Service plan created"

Write-Info "Creating backend web app..."
az webapp create `
    --resource-group $ResourceGroup `
    --plan $appServicePlan `
    --name $backendAppName `
    --runtime "PYTHON:3.11" `
    --output none
Write-Status "Backend web app '$backendAppName' created"

# Generate secret key
$secretKey = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))

# Configure app settings
Write-Info "Configuring backend environment variables..."
az webapp config appsettings set `
    --resource-group $ResourceGroup `
    --name $backendAppName `
    --settings `
        DATABASE_URL=$connectionString `
        AZURE_CLIENT_ID=$azureClientId `
        AZURE_TENANT_ID=$azureTenantId `
        ALLOWED_ORIGINS="https://$frontendAppName.azurestaticapps.net" `
        ALLOWED_ORIGIN_REGEX="^https://.*\.azurestaticapps\.net$" `
        SECRET_KEY=$secretKey `
        LOG_LEVEL="INFO" `
        AUTO_CREATE_TABLES="true" `
        --output none
Write-Status "Environment variables configured"

# ============================================================================
# Phase 5: Deploy Backend Code
# ============================================================================
Write-Info "Preparing backend deployment..."
Push-Location backend

# Initialize git if needed
if (-not (Test-Path .git)) {
    git init
    git add .
    git commit -m "Initial backend deployment"
}

Write-Info "Deploying backend code (this may take 5-10 minutes)..."
az webapp up `
    --resource-group $ResourceGroup `
    --name $backendAppName `
    --skip-app-id-uri-creation `
    --runtime "PYTHON:3.11" `
    --output none

Pop-Location
Write-Status "Backend deployed successfully"

# Verify backend
Write-Info "Verifying backend is running..."
$backendUrl = "https://$backendAppName.azurewebsites.net/health"
$attempt = 0
$maxAttempts = 12
while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri $backendUrl -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Status "Backend is running at: $backendUrl"
            break
        }
    } catch {
        $attempt++
        if ($attempt -lt $maxAttempts) {
            Write-Info "Waiting for backend to start... (attempt $attempt/$maxAttempts)"
            Start-Sleep -Seconds 10
        }
    }
}

if ($attempt -eq $maxAttempts) {
    Write-Error-Custom "Backend failed to start. Check logs with:"
    Write-Error-Custom "  az webapp log tail --resource-group $ResourceGroup --name $backendAppName"
    exit 1
}

# ============================================================================
# Phase 6: Create Static Web App for Frontend
# ============================================================================
Write-Info "Creating Static Web App for frontend..."
az staticwebapp create `
    --name $frontendAppName `
    --resource-group $ResourceGroup `
    --source "." `
    --location $Location `
    --app-location "frontend" `
    --output-location "dist" `
    --skip-github-action-workflow-generation `
    --output none
Write-Status "Static Web App created: $frontendAppName"

# Get Static Web App URL
$staticAppUrl = az staticwebapp show --name $frontendAppName --resource-group $ResourceGroup --query "defaultHostname" -o tsv
Write-Status "Frontend URL: https://$staticAppUrl"

# ============================================================================
# Phase 7: Configure Frontend Environment
# ============================================================================
Write-Info "Configuring frontend environment variables..."
$frontendEnvFile = "frontend\.env"
@"
VITE_API_BASE_URL=https://$backendAppName.azurewebsites.net/api/v1
VITE_AZURE_CLIENT_ID=$azureClientId
VITE_AZURE_TENANT_ID=$azureTenantId
VITE_AZURE_REDIRECT_URI=https://$staticAppUrl/
"@ | Set-Content -Path $frontendEnvFile -Force
Write-Status "Frontend .env file updated"

# ============================================================================
# Phase 8: Update Backend CORS
# ============================================================================
Write-Info "Updating backend CORS configuration..."
az webapp config appsettings set `
    --resource-group $ResourceGroup `
    --name $backendAppName `
    --settings "ALLOWED_ORIGINS=https://$staticAppUrl" `
    --output none
Write-Status "Backend CORS updated for frontend domain"

# ============================================================================
# Phase 9: Update Azure AD Configuration
# ============================================================================
Write-Info "IMPORTANT: Update Azure AD Configuration"
Write-Info "1. Go to Azure Portal → Azure Active Directory → App registrations"
Write-Info "2. Select app with Client ID: $azureClientId"
Write-Info "3. Go to 'Authentication' and add redirect URI:"
Write-Info "   → https://$staticAppUrl/"
Write-Info "4. Save changes"
Write-Info ""
Write-Info "Press ENTER when done..."
Read-Host

# ============================================================================
# Phase 10: Build and Deploy Frontend
# ============================================================================
Write-Info "Building frontend application..."
Push-Location frontend
npm install
npm run build
Pop-Location
Write-Status "Frontend built successfully"

Write-Info "Deploying frontend to Static Web App..."
# Note: Static Web Apps deployment from local build requires GitHub Actions
# Alternatively, use Azure DevOps or manual deployment
Write-Info "To deploy frontend manually:"
Write-Info "  az staticwebapp upload `"
Write-Info "    --name $frontendAppName `"
Write-Info "    --source "./frontend/dist" `"
Write-Info "    --resource-group $ResourceGroup"

# ============================================================================
# Summary & Next Steps
# ============================================================================
Write-Host ""
Write-Host "=" * 80
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "=" * 80
Write-Host ""
Write-Host "Resource Summary:" -ForegroundColor Cyan
Write-Host "  • Resource Group: $ResourceGroup"
Write-Host "  • Database Server: $dbServer ($dbHost)"
Write-Host "  • Database Name: $dbName"
Write-Host "  • Backend App Service: $backendAppName"
Write-Host "  • Backend URL: https://$backendAppName.azurewebsites.net"
Write-Host "  • Frontend Static App: $frontendAppName"
Write-Host "  • Frontend URL: https://$staticAppUrl"
Write-Host ""
Write-Host "Connection Details:" -ForegroundColor Cyan
Write-Host "  • DB Connection String: $connectionString"
Write-Host "  • DB User: $dbUser"
Write-Host "  • DB Password: $dbPassword"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. ✓ Verify backend health: https://$backendAppName.azurewebsites.net/health"
Write-Host "  2. → Update Azure AD redirect URI (see instructions above)"
Write-Host "  3. → Deploy frontend to Static Web App"
Write-Host "  4. → Test login at: https://$staticAppUrl"
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "  • View backend logs:"
Write-Host "    az webapp log tail --resource-group $ResourceGroup --name $backendAppName"
Write-Host "  • Scale up:"
Write-Host "    az appservice plan update --resource-group $ResourceGroup --name $appServicePlan --sku S1"
Write-Host "  • Delete all resources:"
Write-Host "    az group delete --name $ResourceGroup --yes"
Write-Host ""
