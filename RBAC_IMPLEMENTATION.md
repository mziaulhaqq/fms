# Role-Based Access Control (RBAC) Implementation

## 🎯 Overview

The Coal Mining FMS now has comprehensive **Role-Based Access Control (RBAC)** that restricts access to sensitive endpoints based on user roles.

---

## 🔐 Access Control Rules

### Admin-Only Endpoints

The following endpoints require the `admin` role:

1. **Users Management** - `/users` (GET, POST, PATCH, DELETE, toggle-status)
2. **Profit Distributions** - `/profit-distributions` (GET, POST, PATCH, DELETE)
3. **Partners** - `/partners` (GET, POST, PATCH, DELETE)
4. **Income** - `/income` (GET, POST, PATCH, DELETE)
5. **Mining Sites** - `/mining-sites` (GET, POST, PATCH, DELETE)

### Supervisor Restrictions

Users with the `supervisor` role **CANNOT** access:
- User management
- Financial data (profit distributions, income)
- Partner information
- Mining site configuration

Supervisors CAN access:
- Clients
- Expenses & Expense Categories
- Workers & Labor Costs
- Equipment & Production
- Truck Deliveries
- Site Supervisors
- Partner Payouts

---

## 🏗️ Architecture

### Backend Components

#### 1. **RolesGuard** (`server/src/modules/auth/guards/roles.guard.ts`)
Custom guard that:
- Validates user has required roles
- Queries `user_assigned_roles` table with active status
- Joins with `user_roles` to get role names
- Throws `403 Forbidden` if user lacks required role

#### 2. **@Roles() Decorator** (`server/src/modules/auth/decorators/roles.decorator.ts`)
Metadata decorator to specify which roles can access an endpoint:
```typescript
@Roles('admin')  // Only admin users can access
```

#### 3. **Protected Controllers**
All admin-only controllers use:
```typescript
@UseGuards(RolesGuard)
@Roles('admin')
@ApiBearerAuth()
export class UsersController { ... }
```

---

## 📊 Database Schema

### user_roles Table
```sql
id         | integer | Primary Key
name       | varchar | Unique (e.g., 'admin', 'supervisor')
description| text    | Role description
permissions| jsonb   | JSON permissions (future use)
is_active  | boolean | Active status
created_at | timestamp
updated_at | timestamp
```

### user_assigned_roles Table
```sql
id              | integer | Primary Key
user_id         | integer | Foreign Key -> users.id
role_id         | integer | Foreign Key -> user_roles.id
assigned_at     | timestamp
status          | varchar | 'active' or 'inactive'
updated_at      | timestamp
assigned_by     | integer | Foreign Key -> users.id
updated_comment | text
```

### Unique Constraint
- `(user_id, role_id)` must be unique - one user can't have same role twice

---

## 🚀 How It Works

### 1. Login Flow
```
User logs in → JWT token issued → Token contains user ID
```

### 2. Protected Request Flow
```
User makes request → JwtAuthGuard validates token
                  ↓
               RolesGuard checks user's roles
                  ↓
       Query: SELECT user_assigned_roles 
              JOIN user_roles
              WHERE user_id = ? AND status = 'active'
                  ↓
          Compare user's roles with @Roles() metadata
                  ↓
     If role matches → Allow access
     If role missing → 403 Forbidden
```

### 3. SQL Queries

**Check user roles:**
```sql
SELECT 
  uar.id,
  uar.user_id,
  uar.role_id,
  uar.status,
  r.id as role_id,
  r.name as role_name,
  r.is_active
FROM coal_mining.user_assigned_roles uar
LEFT JOIN coal_mining.user_roles r ON r.id = uar.role_id
WHERE uar.user_id = 5 AND uar.status = 'active';
```

---

## 🔧 Setup & Testing

### Step 1: Create Roles
```bash
cd server
./quick-setup-roles.sh
```

This creates:
- `admin` role (ID: 1)
- `supervisor` role (ID: 2)  
- Assigns `admin` role to `testuser`

### Step 2: Start Server
```bash
npm run start:dev
```

### Step 3: Test Admin Access
```bash
# Login as testuser (who has admin role)
TOKEN=$(curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "test123"}' \
  | jq -r '.access_token')

# Should succeed - testuser has admin role
curl -X GET http://localhost:3000/users \
  -H "Authorization: Bearer $TOKEN"

# Should succeed
curl -X GET http://localhost:3000/partners \
  -H "Authorization: Bearer $TOKEN"

# Should succeed
curl -X GET http://localhost:3000/income \
  -H "Authorization: Bearer $TOKEN"
```

### Step 4: Test Supervisor Restrictions

```bash
# Create a supervisor user
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "supervisor1",
    "email": "supervisor@fms.com",
    "password": "super123",
    "fullName": "Site Supervisor",
    "phone": "+1234567890"
  }'

# Assign supervisor role (manually via SQL or API)
# Then login and test - should get 403 on admin endpoints
```

---

## 📱 Mobile App Integration

The Flutter mobile app automatically handles RBAC:

1. **Automatic Token Injection** - `ApiClient` adds JWT to all requests
2. **403 Error Handling** - Shows "Access Denied" message
3. **UI Adjustments** - Can hide admin-only features based on user role

### Example: Hide Admin Menu Items
```dart
final user = await authService.getCurrentUser();
final isAdmin = user['roles']?.contains('admin') ?? false;

if (isAdmin) {
  // Show admin menu items
  ListTile(title: Text('Manage Users')),
  ListTile(title: Text('View Partners')),
  ListTile(title: Text('Financial Reports')),
}
```

---

## 🛡️ Security Features

✅ **Database-Level Role Check** - Roles queried from database, not JWT  
✅ **Active Status Validation** - Only active role assignments counted  
✅ **Guard-Level Protection** - Applied at controller level, not method level  
✅ **Eager Loading** - Roles loaded with relations for performance  
✅ **Status Tracking** - Can deactivate role assignment without deletion  

---

## 🎨 Customization

### Add New Protected Endpoint

```typescript
// 1. Add @UseGuards and @Roles to controller
@Controller('sensitive-data')
@UseGuards(RolesGuard)
@Roles('admin')
@ApiBearerAuth()
export class SensitiveDataController {
  // All methods now require admin role
}
```

### Add New Role

```sql
INSERT INTO coal_mining.user_roles (name, description, is_active)
VALUES ('accountant', 'Financial accountant with limited access', true);
```

### Assign Role to User

```sql
INSERT INTO coal_mining.user_assigned_roles 
  (user_id, role_id, assigned_at, status)
SELECT 
  u.id, 
  r.id, 
  NOW(), 
  'active'
FROM coal_mining.users u, coal_mining.user_roles r
WHERE u.username = 'john' AND r.name = 'accountant';
```

### Multi-Role Endpoints

```typescript
@Roles('admin', 'accountant')  // Allow both admin AND accountant
@Get('financial-reports')
getFinancialReports() { ... }
```

---

## 📝 Available Roles

| Role | ID | Description | Access Level |
|------|-----|-------------|--------------|
| admin | 1 | System Administrator | Full access to all endpoints |
| supervisor | 2 | Site Supervisor | Limited to operational data |
| accountant | 3 | Financial Accountant | Financial management access |
| manager | 4 | Operations Manager | Operational access |
| viewer | 5 | Read-Only | View-only access |

---

## 🔍 Monitoring

### Check User Roles
```sql
SELECT 
  u.username,
  r.name as role_name,
  uar.status,
  uar.assigned_at
FROM coal_mining.user_assigned_roles uar
JOIN coal_mining.users u ON uar.user_id = u.id
JOIN coal_mining.user_roles r ON uar.role_id = r.id
WHERE u.username = 'testuser';
```

### View All Role Assignments
```sql
SELECT 
  u.username,
  u.email,
  string_agg(r.name, ', ') as roles
FROM coal_mining.users u
LEFT JOIN coal_mining.user_assigned_roles uar ON uar.user_id = u.id AND uar.status = 'active'
LEFT JOIN coal_mining.user_roles r ON r.id = uar.role_id
GROUP BY u.id, u.username, u.email
ORDER BY u.username;
```

---

## 🐛 Troubleshooting

### "403 Forbidden" Error
- ✅ Check user has role assigned in database
- ✅ Verify role assignment status is 'active'
- ✅ Ensure role name matches exactly (case-sensitive)
- ✅ Check JWT token is valid and not expired

### Role Not Being Checked
- ✅ Verify `@UseGuards(RolesGuard)` is applied
- ✅ Check `AuthModule` is imported in the module
- ✅ Ensure `TypeOrmModule.forFeature([UserAssignedRoles, UserRoles])` is included

### Database Queries Slow
- ✅ Add index on `user_assigned_roles(user_id, status)`
- ✅ Add index on `user_roles(name)`
- ✅ Use eager loading in RolesGuard

---

## ✅ Summary

Your Coal Mining FMS now has:

1. ✅ **Comprehensive RBAC** restricting admin-only endpoints
2. ✅ **Database-driven role management** with active status tracking
3. ✅ **Secure RolesGuard** checking user permissions on every request
4. ✅ **Multiple role support** (admin, supervisor, accountant, manager, viewer)
5. ✅ **Test user with admin role** (testuser/test123)
6. ✅ **Easy role management** via SQL or future admin UI
7. ✅ **Mobile app integration ready** with automatic 403 handling

All admin-only endpoints are now protected! Supervisors cannot access sensitive financial or user management data. 🎉
