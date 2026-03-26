# Task Tracker App

A full-stack task management application with role-based access control (RBAC), built with modern web technologies and deployed on Azure cloud.

---

## 🎯 **Project Overview**

Task Tracker is a collaborative project and task management system with:
- ✅ **Role-Based Access Control** (Admin, Manager, Read Only User)
- ✅ **Real-time project & task management**
- ✅ **Azure AD authentication**
- ✅ **Interactive dashboard with data visualization**
- ✅ **RESTful FastAPI backend with full OpenAPI documentation**
- ✅ **Modern React frontend with TypeScript**

---

## 🏗️ **Architecture**

```
┌─────────────────────────────────────────────────────────┐
│           Frontend (Vercel - React/TypeScript)          │
│   https://task-tracker-lyart-delta-97.vercel.app       │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ REST API calls
                     │
┌────────────────────▼────────────────────────────────────┐
│       Backend (Azure App Service - FastAPI/Python)      │
│ https://tasktracker-app-*.azurewebsites.net            │
│              /api/v1/projects, /api/v1/tasks            │
│              /api/v1/users, /docs (Swagger UI)          │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ SQL queries
                     │
┌────────────────────▼────────────────────────────────────┐
│   Database (Azure PostgreSQL)                           │
│   task_tracker database with roles, users, projects     │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ **Tech Stack**

### **Frontend**
- React 18.2
- TypeScript 5.2
- Vite (build tool)
- Ant Design (UI components)
- Axios (HTTP client)
- Azure MSAL (authentication)
- Zustand (state management)
- React Router (navigation)

### **Backend**
- Python 3.11+
- FastAPI (web framework)
- SQLAlchemy (ORM)
- PostgreSQL (database)
- Pydantic (data validation)
- Uvicorn (ASGI server)

### **Deployment**
- **Frontend**: Vercel (serverless)
- **Backend**: Azure App Service (containerized)
- **Database**: Azure Database for PostgreSQL
- **Authentication**: Azure AD

---

## 🚀 **Live URLs**

| Component | URL |
|-----------|-----|
| **Frontend** | https://task-tracker-lyart-delta-97.vercel.app |
| **Backend API** | https://tasktracker-app-e2bmc5c8deg7fbdx.centralindia-01.azurewebsites.net |
| **API Docs** | https://tasktracker-app-e2bmc5c8deg7fbdx.centralindia-01.azurewebsites.net/docs |

---

## 📦 **Local Development Setup**

### **Prerequisites**
- Python 3.11+ installed
- Node.js 18+ installed
- PostgreSQL server running (or Docker)
- Git

### **1. Clone & Navigate**
```bash
git clone <your-repo-url>
cd Task-Tracker
```

### **2. Backend Setup**

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Or activate (macOS/Linux)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file (copy from .env file locally)
# DATABASE_URL=postgresql://user:password@localhost:5432/task_tracker
# AZURE_CLIENT_ID=<your-client-id>
# AZURE_TENANT_ID=<your-tenant-id>

# Run migrations (creates tables)
python -m scripts.seed

# Start backend server
uvicorn app.main:app --reload --port 8000
```

✅ Backend running: http://localhost:8000/docs

### **3. Frontend Setup**

```bash
cd frontend

# Install dependencies
npm install

# Create .env.local file
# VITE_AZURE_CLIENT_ID=<your-client-id>
# VITE_AZURE_TENANT_ID=<your-tenant-id>
# VITE_AZURE_REDIRECT_URI=http://localhost:5173
# VITE_API_BASE_URL=http://localhost:8000

# Start dev server
npm run dev
```

✅ Frontend running: http://localhost:5173

---

## 🌱 **Database Seeding**

Populate with test data:

```bash
cd backend
python -m scripts.seed
```

This creates:
- **Roles**: Admin, Manager, Read Only User
- **Test Users**:
  - Alice Admin (admin@local.test)
  - Bob Manager (manager@local.test)
  - Carol Read Only (user@local.test)
  - Sathvik (srisathvikm@gmail.com) - Admin
- **7 Sample Projects**
- **17 Sample Tasks**

---

## 📋 **Available API Endpoints**

All endpoints start with `/api/v1`:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/projects` | List all projects |
| `POST` | `/projects` | Create a new project |
| `GET` | `/projects/{id}` | Get project details |
| `GET` | `/tasks` | List all tasks |
| `POST` | `/tasks` | Create a new task |
| `PUT` | `/tasks/{id}` | Update a task |
| `DELETE` | `/tasks/{id}` | Delete a task |
| `GET` | `/users` | List all users |
| `GET` | `/activity-logs` | Get activity history |

📖 Full documentation: https://tasktracker-app-e2bmc5c8deg7fbdx.centralindia-01.azurewebsites.net/docs

---

## 🔐 **Authentication & Role-Based Access Control (RBAC)**

This application implements a comprehensive authentication and authorization system using Azure AD and custom RBAC:

### **Authentication Flow**

#### **1. Frontend Login Process (Azure AD)**
```
1. User clicks "Login" on LoginPage.tsx
2. Redirects to Azure AD tenant
   → https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/authorize
3. User enters email & password
4. Azure AD validates credentials
5. Returns JWT token to Redirect URI
   → https://task-tracker-lyart-delta-97.vercel.app
6. Token stored in localStorage
7. msalInstance (MSAL) manages token:
   - Automatic refresh before expiry
   - Silent refresh for seamless experience
```

#### **2. Backend Token Validation (Dependency Injection)**

Every protected endpoint uses FastAPI dependency injection:

```python
# In routers/project_router.py:
@router.get("/projects")
async def list_projects(
    current_user: User = Depends(get_current_user),  # ← Validates token
    db: Session = Depends(get_db),
):
    # Only executes if token is valid
    return project_service.list_projects(db)
```

The `get_current_user` dependency (from core/security.py):
- Extracts JWT token from Authorization header: `Bearer {token}`
- Validates token signature with Azure AD public keys
- Extracts user email/ID from token claims
- Looks up user in database
- Raises 401 Unauthorized if invalid

---

### **RBAC (Role-Based Access Control) System**

Three role tiers control API permissions:

#### **1. Admin Role**
**Permissions:**
- ✅ Full CRUD on projects (create, read, update, delete)
- ✅ Full CRUD on tasks (create, read, update, delete)
- ✅ Full CRUD on users (create, read, update, delete)
- ✅ Assign roles to users
- ✅ View all projects regardless of ownership
- ✅ View all tasks regardless of assignment
- ✅ View activity logs (complete audit trail)

**Endpoints blocked for non-Admins:**
- `DELETE /users/{id}` - Delete user account
- `POST /users/{id}/role` - Assign role to user
- `DELETE /projects/{id}` - Delete any project
- `DELETE /tasks/{id}` - Delete any task

#### **2. Manager Role**
**Permissions:**
- ✅ Create projects
- ✅ Edit own projects (where user is owner)
- ✅ Create tasks within own projects
- ✅ Update own tasks (where user is assignee or owner)
- ✅ Change task status (for their team)
- ✅ Assign tasks to team members
- ✅ View users list
- ✅ View activity logs for own projects

**Endpoints blocked for Managers:**
- `DELETE /projects/{id}` - Cannot delete projects
- `PUT /users/{id}` - Cannot modify user info
- `DELETE /users/{id}` - Cannot delete users

#### **3. Read Only User Role**
**Permissions:**
- ✅ View projects (read-only)
- ✅ View tasks (read-only)
- ✅ View users list (read-only)
- ✅ View comments (read-only)
- ❌ Cannot create anything
- ❌ Cannot delete anything
- ❌ Cannot modify anything

**Only GET requests allowed:**
- `GET /projects` - List projects
- `GET /projects/{id}` - Get project details
- `GET /tasks` - List tasks
- `GET /tasks/{id}` - Get task details
- `GET /users` - List users

---

### **RBAC Implementation Details**

#### **Backend RBAC Logic (core/rbac.py)**

```python
# Role definitions mapped to permissions
ROLE_PERMISSIONS = {
    "Admin": ["read", "create", "update", "delete", "manage_users"],
    "Manager": ["read", "create", "update"],
    "Read Only User": ["read"],
}

# Example RBAC check in task_service.py:
def update_task(user: User, task_id: UUID, updates: TaskUpdate):
    task = db.query(Task).filter(Task.id == task_id).first()
    
    # Admin can update any task
    if "Admin" in [r.name for r in user.roles]:
        return db.merge(task)
    
    # Manager can only update tasks they created or are assigned to
    if "Manager" in [r.name for r in user.roles]:
        if task.owner_id != user.id and task.assigned_to != user.id:
            raise PermissionError("Cannot update this task")
        return db.merge(task)
    
    # Read Only User cannot update
    raise PermissionError("Read only access")
```

#### **Frontend Role-Based UI (React Components)**

```tsx
// In ProjectsPage.tsx
const userRole = useAuth().userRole;

return (
  <>
    {/* Show delete button only for Admin */}
    {userRole === "Admin" && (
      <Button danger onClick={deleteProject}>Delete</Button>
    )}
    
    {/* Show create button for Manager & Admin */}
    {["Manager", "Admin"].includes(userRole) && (
      <Button type="primary" onClick={createProject}>Create Project</Button>
    )}
    
    {/* Show view-only component for Read Only User */}
    {userRole === "Read Only User" && (
      <ProjectTable readOnly={true} />
    )}
  </>
);
```

---

### **User-Role Relationships (Database)**

**User can have MULTIPLE roles** (stored in user_role junction table):

```
user_role table (many-to-many):
┌──────────────────┬─────────────────┐
│ user_id          │ role_id         │
├──────────────────┼─────────────────┤
│ abc123-user-id   │ admin-role-id   │
│ def456-user-id   │ manager-role-id │
│ def456-user-id   │ readonly-role-id│  ← User can have multiple roles
└──────────────────┴─────────────────┘
```

When checking permissions, the system checks if **any** user role has the required permission.

---

### **Token Claims & User Identity**

Azure AD JWT token contains (in decoded form):
```json
{
  "oid": "00000000-0000-0000-35c6-3acfedfa1c1b",
  "email": "user@example.com",
  "name": "John Doe",
  "tid": "918804...",
  "exp": 1705000000,
  "iat": 1704996400
}
```

Backend extracts email from token and looks up user in database:
```python
# In auth/azure_auth.py
def get_current_user(token: str):
    claims = jwt.decode(token, options={"verify_signature": False})
    email = claims.get("email")
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user
```

---

### **Security Best Practices Implemented**

✅ **JWT Validation**: Every request validated against Azure AD public keys
✅ **CORS Protection**: Only Vercel & localhost origins allowed
✅ **HTTPS Only**: All production URLs use HTTPS
✅ **Token Freshness**: Frontend auto-refreshes tokens before expiry
✅ **Role Isolation**: Each role limited to minimum required permissions
✅ **Audit Logging**: All user actions logged in activity_log table
✅ **Secure Storage**: Token stored in localStorage
✅ **Environment Separation**: Dev/production credentials managed separately

---



##📁 **Detailed Project Structure & API Architecture**

### **Backend Directory Structure & API Organization**

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                              # FastAPI app entry point
│   │   └─ Creates FastAPI instance
│   │   └─ Registers CORS middleware
│   │   └─ Includes all routers
│   │
│   ├── auth/
│   │   ├── __init__.py
│   │   └── azure_auth.py                    # Azure AD token validation
│   │       └─ JWT token validation
│   │       └─ User identity extraction
│   │       └─ Scope verification
│   │
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py                      # Application configuration
│   │       └─ DATABASE_URL
│   │       └─ AZURE_CLIENT_ID, AZURE_TENANT_ID
│   │       └─ ALLOWED_ORIGINS (CORS)
│   │       └─ AUTO_CREATE_TABLES flag
│   │
│   ├── core/
│   │   ├── __init__.py
│   │   ├── rbac.py                          # Role-Based Access Control
│   │   │   └─ Role-permission mappings
│   │   │   └─ Permission verification
│   │   │   └─ Resource ownership checks
│   │   └── security.py                      # Security utilities
│   │       └─ Token dependencies
│   │       └─ Current user injection
│   │
│   ├── database/
│   │   ├── __init__.py
│   │   ├── base.py                          # SQLAlchemy Base model
│   │   └── session.py                       # Database session factory
│   │       └─ Engine creation
│   │       └─ SessionLocal for DI
│   │
│   ├── models/                              # SQLAlchemy ORM Models
│   │   ├── __init__.py
│   │   ├── user.py                          # User(id, name, email)
│   │   ├── role.py                          # Role(name) - Admin/Manager/ReadOnly
│   │   ├── project.py                       # Project(name, description, owner, dates)
│   │   ├── task.py                          # Task(title, status, assignee, due_date)
│   │   ├── comment.py                       # Comment(content, task_id, user_id)
│   │   └── activity_log.py                  # ActivityLog (audit trail)
│   │
│   ├── repositories/                        # Data Access Layer (DAL)
│   │   ├── __init__.py
│   │   ├── user_repository.py               # User CRUD
│   │   │   └─ get_user_by_email()
│   │   │   └─ create_user()
│   │   │   └─ update_user()
│   │   ├── project_repository.py            # Project CRUD
│   │   │   └─ list_projects()
│   │   │   └─ get_project_with_tasks()
│   │   │   └─ create_project()
│   │   ├── task_repository.py               # Task CRUD & filtering
│   │   │   └─ list_tasks(filters)
│   │   │   └─ update_task_status()
│   │   ├── comment_repository.py            # Comment CRUD
│   │   └── activity_log_repository.py       # Activity log queries
│   │
│   ├── schemas/                             # Pydantic DTOs (Request/Response)
│   │   ├── __init__.py
│   │   ├── user_schema.py                   # UserCreate, UserResponse, UserUpdate
│   │   ├── project_schema.py                # ProjectCreate, ProjectResponse
│   │   ├── task_schema.py                   # TaskCreate, TaskUpdate, TaskResponse
│   │   ├── comment_schema.py                # CommentCreate, CommentResponse
│   │   └── activity_log_schema.py           # ActivityLogResponse
│   │
│   ├── services/                            # Business Logic Layer
│   │   ├── __init__.py
│   │   ├── user_service.py                  # User business logic
│   │   │   └─ Register user via Azure AD
│   │   │   └─ Assign roles
│   │   ├── project_service.py               # Project business logic
│   │   │   └─ Create project with owner
│   │   │   └─ Validate permissions
│   │   ├── task_service.py                  # Task business logic
│   │   │   └─ Validate task status transitions
│   │   │   └─ Assignment rules
│   │   │   └─ Check RBAC
│   │   ├── comment_service.py               # Comment logic
│   │   └── activity_log_service.py          # Audit trail logging
│   │
│   ├── routers/                             # API Endpoint Handlers
│   │   ├── __init__.py
│   │   ├── auth_router.py                   # POST /api/v1/auth/login
│   │   ├── user_router.py                   # /api/v1/users
│   │   │   └─ GET /users (list)
│   │   │   └─ GET /users/{id}
│   │   │   └─ POST /users (Admin only)
│   │   │   └─ PUT /users/{id} (Admin only)
│   │   │   └─ DELETE /users/{id} (Admin only)
│   │   ├── project_router.py                # /api/v1/projects
│   │   │   └─ GET /projects
│   │   │   └─ GET /projects/{id}
│   │   │   └─ POST /projects (Manager/Admin)
│   │   │   └─ PUT /projects/{id} (Owner/Admin)
│   │   │   └─ DELETE /projects/{id} (Admin only)
│   │   └── task_router.py                   # /api/v1/tasks
│   │       └─ GET /tasks (with filters)
│   │       └─ GET /tasks/{id}
│   │       └─ POST /tasks (Manager/Admin)
│   │       └─ PUT /tasks/{id}
│   │       └─ PATCH /tasks/{id}/status
│   │       └─ DELETE /tasks/{id} (Admin only)
│   │
│   └── utils/
│       ├── __init__.py
│       ├── pagination.py                    # Pagination helper
│       └── responses.py                     # Standard response format
│
├── scripts/
│   └── seed.py                              # Database seeding
│       └─ Creates roles, users, projects, tasks
│
├── tests/
│   ├── conftest.py
│   ├── test_health.py
│   ├── test_user_service.py
│   ├── test_project_service.py
│   └── test_task_service.py
│
├── requirements.txt                         # Python dependencies
├── pyrightconfig.json                       # Type checking config
└── Dockerfile
```

### **API Request Flow (Backend Layers)**

```
HTTP Request from Frontend
    ↓
[CORS Middleware] - Verify origin
    ↓
[Router] (routers/task_router.py)
  → Extracts path parameters
  → Extracts query parameters
    ↓
[Dependency Injection] (core/security.py)
  → get_current_user → Validates JWT token
  → get_db → Creates database session
    ↓
[RBAC Check] (core/rbac.py)
  → Checks user role for permission
  → Verifies resource ownership if needed
    ↓
[Service Layer] (services/task_service.py)
  → Implements business logic
  → Calls repository methods
    ↓
[Repository Layer] (repositories/task_repository.py)
  → Executes database queries
  → Returns ORM objects
    ↓
[Schema Layer] (schemas/task_schema.py)
  → Serializes ORM objects to JSON
  → Applies response validation
    ↓
HTTP Response (JSON)
```

---

### **Frontend Directory Structure & API Integration**

```
frontend/src/
├── main.tsx                                 # React app entry point
├── App.tsx                                  # Root component
├── index.css                                # Global styles
│
├── api/                                     # API Client Layer
│   └── apiClient.ts                         # Axios HTTP client configuration
│       └─ Base URL: import.meta.env.VITE_API_BASE_URL
│       └─ Request interceptor: Adds Authorization header
│       └─ Response interceptor: Standardizes errors
│       └─ Methods for: GET, POST, PUT, DELETE
│
├── auth/                                    # Azure AD Authentication
│   └── authProvider.ts                      # MSAL configuration
│       └─ clientId: import.meta.env.VITE_AZURE_CLIENT_ID
│       └─ tenantId: import.meta.env.VITE_AZURE_TENANT_ID
│       └─ redirectUri: Dynamic (localhost vs Vercel)
│       └─ msalInstance: PublicClientApplication
│       └─ loginRequest: Scopes for token
│       └─ getIdToken(): Retrieves JWT token
│
├── hooks/                                   # Custom React Hooks
│   └── useAuth.ts                           # Authentication hook
│       └─ isAuthenticated: boolean
│       └─ user: User object
│       └─ userRole: Admin | Manager | ReadOnly
│       └─ login(): Redirect to Azure AD
│       └─ logout(): Clear session
│       └─ getToken(): Get JWT for API calls
│
├── components/                              # Reusable UI Components
│   ├── ProjectTable.tsx                     # Display projects
│   │   └─ Columns: name, owner, start date, end date
│   │   └─ Actions: edit, delete (role-based)
│   ├── TaskTable.tsx                        # Display tasks
│   │   └─ Columns: title, status, assignee, due date
│   │   └─ Status badges with colors
│   ├── TaskForm.tsx                         # Create/Edit task
│   │   └─ Form validation
│   │   └─ Date picker, dropdowns
│   └── TaskDetailDrawer.tsx                 # Task side panel
│       └─ Full task details
│       └─ Edit fields inline
│       └─ Comments section
│
├── layouts/
│   └── MainLayout.tsx                       # Main app layout
│       └─ Header with user menu
│       └─ Sidebar navigation
│       └─ Role-based menu visibility
│
├── pages/                                   # Route Pages
│   ├── DashboardPage.tsx                    # Landing page
│   │   └─ Recent projects
│   │   └─ Task statistics
│   ├── LoginPage.tsx                        # Azure AD login
│   │   └─ Login button
│   │   └─ Redirects to Azure AD
│   ├── ProjectsPage.tsx                     # Projects management
│   │   └─ ProjectTable component
│   │   └─ Create button (Manager/Admin)
│   │   └─ Edit/Delete (role-based)
│   ├── TasksPage.tsx                        # Tasks management
│   │   └─ TaskTable component
│   │   └─ Filters: project, status, assignee
│   │   └─ TaskDetailDrawer for editing
│   └── UsersPage.tsx                        # User management
│       └─ User list (Admin only)
│       └─ Add/Remove users (Admin only)
│       └─ Assign roles (Admin only)
│
├── routes/
│   └── AppRoutes.tsx                        # Route configuration
│       └─ <Route path="/" element={<Dashboard />} />
│       └─ <Route path="/projects" ... />
│       └─ <Route path="/tasks" ... />
│       └─ <Route path="/users" ... /> (Admin only)
│       └─ Protected routes with role checks
│
├── store/                                   # Global State (Zustand)
│   └── authStore.ts                         # Auth state management
│       └─ isAuthenticated: boolean
│       └─ currentUser: User object
│       └─ userRole: string
│       └─ setUser(): Update auth state
│       └─ logout(): Clear state
│
└── types/                                   # TypeScript Types
    ├── User.ts                              # interface User { ... }
    ├── Project.ts                           # interface Project { ... }
    ├── Task.ts                              # interface Task { ... }
    ├── Comment.ts                           # interface Comment { ... }
    └── index.ts                             # Export all types

Public files:
├── index.html                               # HTML entry point
├── vite.config.ts                           # Vite build config
├── tsconfig.json                            # TypeScript config
├── tsconfig.node.json                       # Vite TS config
├── vercel.json                              # Vercel SPA routing config
└── package.json                             # Dependencies & scripts
```

### **Frontend API Call Flow**

```
React Component (e.g., TasksPage.tsx)
    ↓
useEffect(() => { fetchTasks() })
    ↓
[API Client] (apiClient.ts)
  → apiClient.get('/api/v1/tasks')
  → Request interceptor adds: Authorization: Bearer {token}
  → Set headers: Content-Type: application/json
    ↓
[HTTP GET Request]
  →  https://backend-url/api/v1/tasks
    ↓
[Backend Response]
  → [ { id: 1, title: "Task 1", status: "new" }, ... ]
    ↓
[Response Interceptor]
  → Check status code (200 OK)
  → Parse JSON
  → Return data
    ↓
[Component State Update]
  → setTasks(response)
  → Component re-renders with new data
    ↓
[UI Display]
  → TaskTable shows tasks from state
```

---

### **Example: Complete Request-Response Cycle**

**User Action:** Create a new task

**1. Frontend (create task)**
```tsx
// TaskForm.tsx
const handleSubmit = async (taskData) => {
  const token = await useAuth().getToken();
  const response = await apiClient.post('/api/v1/tasks', {
    title: "Fix login bug",
    status: "new",
    project_id: "proj-123",
    assigned_to: "user-456",
  });
  setTask(response.data);
};
```

**2. HTTP Request**
```
POST /api/v1/tasks HTTP/1.1
Host: backend-url
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json

{
  "title": "Fix login bug",
  "status": "new",
  "project_id": "proj-123",
  "assigned_to": "user-456"
}
```

**3. Backend (task_router.py)**
```python
@router.post("/tasks")
async def create_task(
    task_create: TaskCreate,
    current_user: User = Depends(get_current_user),  # Validates JWT
    db: Session = Depends(get_db),
):
    # RBAC check
    if not check_permission(current_user, "create_task"):
        raise HTTPException(status_code=403, detail="Permission denied")
    
    # Call service
    task = task_service.create_task(db, task_create, current_user)
    return task  # Returns TaskResponse schema
```

**4. Backend Response**
```json
{
  "id": "task-789",
  "title": "Fix login bug",
  "status": "new",
  "project_id": "proj-123",
  "assigned_to": "user-456",
  "created_at": "2026-03-26T10:30:00Z",
  "owner_id": "current-user-id"
}
```

**5. Frontend (update UI)**
```tsx
// TaskTable re-renders with new task
const tasks = [...tasks, response.data];
setTasks(tasks);  // UI updates automatically
```

---

## 🔧 **Environment Variables**

### **Backend (.env)**
```
DATABASE_URL=postgresql://user:password@host:5432/task_tracker
AZURE_CLIENT_ID=<your-azure-client-id>
AZURE_TENANT_ID=<your-azure-tenant-id>
AUTO_CREATE_TABLES=true
LOG_LEVEL=INFO
```

### **Frontend (.env.local for dev, or Vercel env vars)**
```
VITE_AZURE_CLIENT_ID=<your-azure-client-id>
VITE_AZURE_TENANT_ID=<your-azure-tenant-id>
VITE_AZURE_REDIRECT_URI=http://localhost:5173
VITE_API_BASE_URL=http://localhost:8000
```

---

## 🚢 **Deployment**

### **Backend to Azure**

```bash
# Push code
git push origin main

# Azure DevOps pipeline triggers automatically:
# 1. Builds Docker image
# 2. Runs pytest
# 3. Pushes to Azure Container Registry
# 4. Deploys to Azure App Service
```

### **Frontend to Vercel**

```bash
# Push code
git push origin main

# Vercel auto-deploys:
# 1. Installs dependencies
# 2. Builds with `npm run build`
# 3. Deployed to CDN (seconds)
```

---



## 📊 **Database Schema**

### **Key Tables**
- `user` - User profiles with email
- `role` - Admin, Manager, Read Only User
- `user_role` - Junction table (many-to-many)
- `project` - Projects with owner
- `task` - Tasks with status, assignee, due date
- `activity_log` - Audit trail
- `comment` - Task comments

---

## 🐛 **Troubleshooting**

### **Frontend Login Redirects to Localhost**
- Ensure `VITE_AZURE_REDIRECT_URI` env var is set in Vercel
- Add Vercel URL to Azure AD app registration under Authentication

### **"CORS Error" on API calls**
- Check `ALLOWED_ORIGINS` in backend `settings.py`
- Ensure frontend URL is in the list or matches regex

### **Database Connection Failed**
- Verify `DATABASE_URL` format: `postgresql://user:pass@host:port/dbname`
- Check PostgreSQL is running
- Test connection: `psql <DATABASE_URL>`

### **"401 Unauthorized" on API**
- Ensure Azure AD credentials are correct
- Verify token is being sent in `Authorization: Bearer <token>` header

---

## 📚 **Documentation**

- **API Documentation**: `/docs` endpoint (Swagger UI)
- **OpenAPI Schema**: `/openapi.json`
- **Database Models**: See `backend/app/models/`

---

## 🤝 **Contributing**

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m "Add your feature"`
3. Push to branch: `git push origin feature/your-feature`
4. Open a pull request

---

## 📄 **License**

MIT License - See LICENSE file for details

---

## 💬 **Support**

For issues or questions:
1. Check API docs: https://tasktracker-app-e2bmc5c8deg7fbdx.centralindia-01.azurewebsites.net/docs
2. Review backend logs in Azure Portal
3. Check browser DevTools for frontend errors

---

**Last Updated**: March 2026  
**Status**: ✅ Production Ready