# Azure Management Commands Reference

## Quick Variables Setup
```powershell
$rg = "task-tracker-rg"              # Resource Group
$backendApp = "task-tracker-api-xyz" # Your backend app name
$frontendApp = "task-tracker-app-xyz" # Your frontend app name
$dbServer = "task-tracker-db-server-1234" # Your DB server name
```

---

## Backend App Service Commands

### 🔍 Monitoring & Logs
```powershell
# View live logs (stream mode)
az webapp log tail --resource-group $rg --name $backendApp --provider web

# View last 100 lines of logs
az webapp log show --resource-group $rg --name $backendApp --provider web

# Download log files
az webapp log download --resource-group $rg --name $backendApp --log-file

# Check deployment status
az webapp deployment show --resource-group $rg --name $backendApp
```

### 🔧 Configuration
```powershell
# View all app settings
az webapp config appsettings list --resource-group $rg --name $backendApp

# Update single setting
az webapp config appsettings set --resource-group $rg --name $backendApp `
  --settings DATABASE_URL="postgresql://..."

# View all configuration
az webapp config show --resource-group $rg --name $backendApp

# Enable HTTPS only
az webapp update --resource-group $rg --name $backendApp --https-only true
```

### 🚀 Deployment & Restart
```powershell
# Restart the app
az webapp restart --resource-group $rg --name $backendApp

# Stop the app (to save costs)
az webapp stop --resource-group $rg --name $backendApp

# Start the app
az webapp start --resource-group $rg --name $backendApp

# Deploy from local git
az webapp up --resource-group $rg --name $backendApp --runtime "PYTHON:3.11"
```

### 📊 Scale & Performance
```powershell
# Get App Service Plan
az appservice plan list --resource-group $rg

# Scale up to higher tier
az appservice plan update --resource-group $rg --name task-tracker-plan --sku S1

# View resource usage
az monitor metrics list --resource /subscriptions/{id}/resourceGroups/$rg/providers/Microsoft.Web/sites/$backendApp
```

### 🔐 Security
```powershell
# List SSL certificates
az webapp ssl list --resource-group $rg --name $backendApp

# Add custom domain
az webapp config hostname add --resource-group $rg --webapp-name $backendApp --hostname myapp.com

# Enable managed identity
az webapp identity assign --resource-group $rg --name $backendApp
```

---

## Frontend Static Web App Commands

### 🔍 Monitoring
```powershell
# View Static Web App details
az staticwebapp show --name $frontendApp --resource-group $rg

# List all builds
az staticwebapp environment list --name $frontendApp --resource-group $rg

# View specific build logs
az staticwebapp environment show --name $frontendApp --environment-name "production" --resource-group $rg
```

### 🔧 Configuration
```powershell
# View app settings
az staticwebapp appsettings list --name $frontendApp --resource-group $rg

# Update app settings
az staticwebapp appsettings set --name $frontendApp --resource-group $rg `
  --setting-names VITE_API_BASE_URL="https://..."

# Create forwarding rule (route to backend)
az staticwebapp routes create --name $frontendApp --resource-group $rg `
  --route-template "/api/*" --route-method GET `
  --route-origin "https://task-tracker-api-xyz.azurewebsites.net"
```

### 🚀 Deployment
```powershell
# Deploy from local
az staticwebapp upload --name $frontendApp --source "./dist" --resource-group $rg

# Force rebuild
az staticwebapp environment create --name $frontendApp --environment-name "staging" --resource-group $rg
```

### 🔐 Custom Domain
```powershell
# Add custom domain
az staticwebapp custom-domain create --name $frontendApp --resource-group $rg `
  --domain-name app.yourdomain.com

# List custom domains
az staticwebapp custom-domain list --name $frontendApp --resource-group $rg

# Remove custom domain
az staticwebapp custom-domain delete --name $frontendApp --resource-group $rg `
  --domain-name app.yourdomain.com
```

---

## Database Commands

### 🔍 PostgreSQL Server
```powershell
# Show server details
az postgres server show --resource-group $rg --name $dbServer

# List databases
az postgres db list --resource-group $rg --server-name $dbServer

# View firewall rules
az postgres server firewall-rule list --resource-group $rg --server-name $dbServer
```

### 🔧 Configuration
```powershell
# Update admin password
az postgres server update --resource-group $rg --name $dbServer `
  --admin-password "NewPassword@123"

# Enable SSL enforcement
az postgres server update --resource-group $rg --name $dbServer `
  --ssl-enforcement ENABLED

# Update storage
az postgres server update --resource-group $rg --name $dbServer `
  --storage-size 102400
```

### 📊 Scale Database
```powershell
# Scale to higher tier
az postgres server update --resource-group $rg --name $dbServer `
  --sku-name B_Gen5_2

# Available SKUs: B_Gen5_1, B_Gen5_2, GP_Gen5_4, GP_Gen5_8, MO_Gen5_16
```

### 🔒 Firewall & Security
```powershell
# Add firewall rule for IP range
az postgres server firewall-rule create --resource-group $rg --server-name $dbServer `
  --name "Office" --start-ip-address 203.0.113.0 --end-ip-address 203.0.113.255

# Allow all Azure services
az postgres server firewall-rule create --resource-group $rg --server-name $dbServer `
  --name "AllowAzureServices" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Delete firewall rule
az postgres server firewall-rule delete --resource-group $rg --server-name $dbServer `
  --name "Office"
```

### 🗑️ Backup & Restore
```powershell
# List backups
az postgres server-logs list --resource-group $rg --server-name $dbServer

# Restore from backup
az postgres server restore --resource-group $rg --name $dbServer-restored `
  --source-server $dbServer --restore-point-in-time "2024-01-15T10:00:00"
```

---

## Resource Group & Billing

### 💰 Cost & Billing
```powershell
# Estimate costs
az billing invoice list

# View resource consumption
az monitor metrics list --resource /subscriptions/{id}/resourceGroups/$rg `
  --interval PT1H --metric "Percentage CPU"

# Get cost breakdown
az costmanagement cost forecast list --timeframe Month --type Usage
```

### 🗑️ Cleanup & Deletion
```powershell
# List all resources in group
az resource list --resource-group $rg

# Delete specific app (keep resources)
az webapp delete --resource-group $rg --name $backendApp

# Delete entire resource group (WARNING: Deletes everything!)
az group delete --resource-group $rg --yes

# Preview deletion (dry run)
az group delete --resource-group $rg --no-wait
```

---

## Networking & DNS

### 🌐 DNS Configuration
```powershell
# Create DNS record (requires DNS management access)
az network dns record-set a create --resource-group $rg --zone-name yourdomain.com `
  --name app --ttl 3600 --target-resource "$(az staticwebapp show -n $frontendApp -g $rg --query id -o tsv)"

# Get DNS records
az network dns record-set list --resource-group $rg --zone-name yourdomain.com
```

---

## Useful Advanced Commands

### 🔄 CI/CD Pipeline Status
```powershell
# Get deployment details
az webapp deployment user show

# List recent deployments
az webapp deployment slot list --resource-group $rg --name $backendApp --query "[].{slot:name,state:state}"

# Check deployment status
az provider operation show --namespace Microsoft.Web --operation-name sites/deploy/action
```

### 📈 Auto-scaling
```powershell
# Create auto-scale rule
az monitor autoscale create --resource-group $rg --resource-name task-tracker-plan `
  --resource-type "Microsoft.Web/serverfarms" --min-count 1 --max-count 5 --count 2

# List auto-scale settings
az monitor autoscale list --resource-group $rg

# Delete auto-scale
az monitor autoscale delete --resource-group $rg --name task-tracker-plan
```

### 🏥 Health Check & Diagnostics
```powershell
# Diagnostic settings
az monitor diagnostic-settings create --name "AppServiceDiagnostics" `
  --resource /subscriptions/{id}/resourceGroups/$rg/providers/Microsoft.Web/sites/$backendApp `
  --logs @logs.json --metrics @metrics.json

# Check web app health
curl https://$backendApp.azurewebsites.net/health
```

---

## Debugging Common Issues

### 🔴 503 Service Unavailable
```powershell
# Check if app is running
az webapp show --resource-group $rg --name $backendApp --query state

# Restart app
az webapp restart --resource-group $rg --name $backendApp

# Check logs
az webapp log tail --resource-group $rg --name $backendApp
```

### 🔴 502 Bad Gateway
```powershell
# Usually startup timeout - check requirements.txt dependency
az webapp config appsettings list --resource-group $rg --name $backendApp

# Increase timeout
az webapp config set --resource-group $rg --name $backendApp `
  --funcs-worker-process-count 1
```

### 🔴 Connection Timeout to Database
```powershell
# Verify firewall allows Azure services
az postgres server firewall-rule show --resource-group $rg --server-name $dbServer `
  --name "AllowAzureServices"

# Test connection
psql -U dbadmin@$dbServer -h $dbServer.postgres.database.azure.com -d task_tracker
```

---

## Quick Cheat Sheet

| Task | Command |
|------|---------|
| View logs | `az webapp log tail -g $rg -n $backendApp` |
| Restart backend | `az webapp restart -g $rg -n $backendApp` |
| View settings | `az webapp config appsettings list -g $rg -n $backendApp` |
| Update setting | `az webapp config appsettings set -g $rg -n $backendApp --settings KEY="VALUE"` |
| Scale up | `az appservice plan update -g $rg -n task-tracker-plan --sku S1` |
| Deploy frontend | `az staticwebapp upload -n $frontendApp -g $rg --source "./dist"` |
| Stop app | `az webapp stop -g $rg -n $backendApp` |
| Delete everything | `az group delete -g $rg --yes` |

---

For more help: `az --help` or visit https://learn.microsoft.com/cli/azure/
