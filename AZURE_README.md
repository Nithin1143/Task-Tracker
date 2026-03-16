# Task Tracker - Azure Deployment Package

## 📦 Contents of This Package

This package contains everything needed to deploy Task Tracker to Azure Cloud.

### Documentation Files
1. **AZURE_QUICK_START.md** ⭐ START HERE
   - 5-step quick deployment guide
   - ~20-30 minutes from start to finish
   - Best for first-time deployment

2. **AZURE_DEPLOYMENT_GUIDE.md**
   - Comprehensive step-by-step guide
   - Detailed explanation of each step
   - Troubleshooting section
   - For learning and understanding

3. **AZURE_COMMANDS_REFERENCE.md**
   - Complete CLI command reference
   - Management and scaling commands
   - Debugging and diagnostics

### Deployment Scripts
1. **deploy-to-azure.ps1** (PowerShell)
   - Fully automated deployment
   - Creates all resources
   - Requires: PowerShell 5.1+, Azure CLI

### Configuration Files
1. **backend/startup.sh**
   - Production startup script for App Service
   - Uses Gunicorn + Uvicorn

2. **backend/requirements.txt**
   - Updated with Gunicorn dependency

3. **frontend/staticwebapp.config.json**
   - Azure Static Web App configuration
   - Routes and CORS settings

4. **frontend/.env**
   - Environment variables template
   - Will be auto-populated during deployment

---

## 🚀 Quick Start (5 Steps)

### Prerequisites
- Azure subscription (free at https://azure.microsoft.com/free)
- Azure CLI (https://aka.ms/cli)
- Git
- Node.js 16+
- PowerShell 5.1+

### Deploy
```powershell
# Step 1: Login
az login

# Step 2: Run automated script
.\deploy-to-azure.ps1

# Step 3: Update Azure AD (manual step - script will pause and guide you)

# Step 4: Build frontend
cd frontend
npm install
npm run build

# Step 5: Deploy frontend
az staticwebapp upload --name <app-name> --source "./dist" --resource-group task-tracker-rg
```

---

## 📋 Azure Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Cloud Platform                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐    ┌──────────────────┐                 │
│  │  Static Web App  │    │  App Service     │                 │
│  │  (React Frontend)│    │  (FastAPI Backend)                │
│  │                  │───→│  - Python 3.11   │                 │
│  │  - Vite Build    │    │  - Uvicorn       │                 │
│  │  - React Router  │    │  - 4 Workers     │                 │
│  │  - MSAL Auth     │    │                  │                 │
│  └──────────────────┘    └───────┬──────────┘                 │
│         ↓                         ↓                             │
│      Public IP              Internal IP:8000                   │
│     azurestaticapps.net     azurewebsites.net                 │
│                                   │                             │
│                                   ↓                             │
│                         ┌──────────────────────┐               │
│                         │  PostgreSQL Server   │               │
│                         │  - Single Server B1  │               │
│                         │  - Managed Database  │               │
│                         │  - Encrypted SSL     │               │
│                         │  - Automated Backup  │               │
│                         └──────────────────────┘               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Configuration

### Azure AD Authentication
- Client ID: `0842ec45-61b4-405c-8a1f-f5c8d1b2329a`
- Tenant ID: `931f45cb-5916-4f22-a21b-af7a33509960`
- Redirect URI: `https://<your-frontend>.azurestaticapps.net/`

### CORS Configuration
- Frontend origin: `https://<frontend-name>.azurestaticapps.net`
- Backend allows all `*.azurestaticapps.net` domains via regex
- SSL/TLS enforced on PostgreSQL connections

### Network Security
- PostgreSQL firewall rules configured
- Static Web App behind Azure CDN
- App Service uses managed identities (future)

---

## 💰 Cost Estimation

### Monthly Costs (Production)
| Resource | Tier | Cost/Month |
|----------|------|-----------|
| PostgreSQL | Single Server B1 | ~$30 |
| App Service | B1 Linux | ~$13 |
| Static Web App | Free | Free |
| | **Total** | **~$43** |

### Cost Optimization Tips
1. Use free tier during development
2. Stop app when not in use: `az webapp stop`
3. Delete unused resources: `az group delete`
4. Use lower DB tier initially, scale up as needed

---

## 🔄 Deployment Workflow

### First-Time Deployment (Manual)
1. Run `deploy-to-azure.ps1`
2. Update Azure AD redirect URI
3. Build frontend with `npm run build`
4. Deploy with `az staticwebapp upload`

### Subsequent Deployments (Manual)
```powershell
# Backend updates
cd backend
git add .
git commit -m "Backend update"
az webapp up -g task-tracker-rg -n task-tracker-api-xyz

# Frontend updates
cd frontend
npm run build
az staticwebapp upload -n task-tracker-app-xyz -g task-tracker-rg --source "./dist"
```

### Future: GitHub Actions (Optional)
Set up CI/CD for automatic deployments on git push.

---

## ✅ Post-Deployment Verification

### 1. Test Backend Health
```powershell
curl https://task-tracker-api-xyz.azurewebsites.net/health
# Expected: {"status":"ok"}
```

### 2. Test Frontend
1. Open `https://<frontend-name>.azurestaticapps.net`
2. Click "Login with Azure AD"
3. Authenticate
4. Verify dashboard loads

### 3. Test Database
```powershell
# Verify connection from backend logs
az webapp log tail -g task-tracker-rg -n task-tracker-api-xyz

# Look for: "Database schema checked/created successfully"
```

---

## 🐛 Troubleshooting

### Login Not Working
- [ ] Verify Azure AD redirect URI is configured
- [ ] Check `VITE_API_BASE_URL` in frontend env
- [ ] View backend logs: `az webapp log tail`
- [ ] Test in incognito window

### Backend Not Responding
- [ ] Check if app is running: `az webapp show --query state`
- [ ] Restart app: `az webapp restart`
- [ ] View logs: `az webapp log tail`
- [ ] Scale up if CPU high: `az appservice plan update --sku S1`

### Database Connection Failed
- [ ] Verify firewall allows Azure services
- [ ] Check connection string format
- [ ] Verify DB server is running: `az postgres server show`
- [ ] Test locally with psql

### Frontend Not Building
- [ ] Clear cache: `rm -r node_modules package-lock.json`
- [ ] Reinstall: `npm install --force`
- [ ] Build: `npm run build`
- [ ] Upload: `az staticwebapp upload`

---

## 📚 Resource Links

### Azure Documentation
- [App Service Python](https://learn.microsoft.com/azure/app-service/quickstart-python)
- [Static Web Apps React](https://learn.microsoft.com/azure/static-web-apps/getting-started?tabs=react)
- [PostgreSQL Server](https://learn.microsoft.com/azure/postgresql/single-server/)
- [Azure CLI Reference](https://learn.microsoft.com/cli/azure/)

### Project Documentation
- [Backend README](backend/README.md) - FastAPI setup
- [Frontend README](frontend/README.md) - React setup
- [Main README](README.md) - Project overview

---

## 🎯 Next Steps

### Immediate (After Deployment)
1. Test all login flows
2. Verify API calls work
3. Create test projects/tasks
4. Check database has data

### Short-term (1 week)
1. Set up monitoring/alerts
2. Configure custom domain (optional)
3. Enable auto-backup
4. Document deployment procedures

### Long-term (1 month+)
1. Implement CI/CD with GitHub Actions
2. Set up staging environment
3. Configure secrets management
4. Plan scaling strategy

---

## 📞 Support & Help

### Getting Help
1. Check troubleshooting section above
2. Review Azure CLI help: `az --help`
3. Search Azure documentation
4. Check application logs

### Important Files to Check
- Backend logs: `az webapp log tail -g task-tracker-rg -n task-tracker-api-xyz`
- Frontend build: Check `frontend/dist` directory
- Environment vars: `az webapp config appsettings list`
- Database: `psql -h <server>.postgres.database.azure.com`

---

## ✨ Success Indicators

You'll know deployment was successful when:
- ✅ Backend health check returns `{"status":"ok"}`
- ✅ Frontend loads without CORS errors
- ✅ Login redirects to Azure AD
- ✅ Dashboard displays user info after login
- ✅ Can create projects/tasks
- ✅ Data persists in database

---

**Last Updated**: March 16, 2026
**Version**: 1.0
**Author**: GitHub Copilot / Task Tracker Team
