# Authentication Implementation Guide

## 🔐 Overview

The Coal Mining FMS uses **JWT (JSON Web Token)** authentication to secure API endpoints. This document explains the complete authentication flow between the NestJS backend and Flutter mobile app.

---

## 🏗️ Architecture

### Backend (NestJS)
- **Strategy**: Passport JWT + Local Strategy
- **Token Type**: Bearer Token (JWT)
- **Token Expiry**: 24 hours
- **Global Guard**: All routes are protected by default except those marked with `@Public()`

### Mobile App (Flutter)
- **Storage**: `flutter_secure_storage` for JWT tokens
- **HTTP Client**: Dio with automatic token injection
- **Error Handling**: Automatic redirect to login on 401 errors

---

## 🔄 Authentication Flow

### 1. User Login

**Request:**
```http
POST /auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**Response (Success):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@fms.com",
    "fullName": "System Administrator",
    "phone": "+1234567890",
    "isActive": true
  }
}
```

**What Happens:**
1. User enters username/email and password in mobile app
2. App sends POST request to `/auth/login`
3. Backend validates credentials using `LocalStrategy`
4. If valid, backend generates JWT token with user info
5. Mobile app stores token in `flutter_secure_storage`
6. User is redirected to dashboard

### 2. Making Authenticated Requests

**Request:**
```http
GET /clients
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**What Happens:**
1. Mobile app makes API call (e.g., get clients)
2. Dio interceptor automatically adds `Authorization` header with stored token
3. Backend's `JwtAuthGuard` validates the token
4. If valid, request proceeds; if invalid, returns 401
5. Mobile app receives data or error

### 3. Token Expiration / 401 Error

**What Happens:**
1. Token expires or is invalid
2. Backend returns `401 Unauthorized`
3. Dio interceptor catches the error
4. Mobile app:
   - Clears stored tokens
   - Shows "Session expired" message
   - Redirects user to login screen

### 4. User Logout

**What Happens:**
1. User clicks logout in mobile app
2. App deletes tokens from secure storage
3. User is redirected to login screen

---

## 📱 Mobile App Implementation

### Key Components

#### 1. **AuthService** (`lib/services/auth_service.dart`)
- Handles login/logout
- Manages JWT token storage
- Provides user info methods

```dart
final authService = AuthService();

// Login
final result = await authService.login('admin', 'admin123');
if (result['success']) {
  // Navigate to dashboard
}

// Check if logged in
final isLoggedIn = await authService.isLoggedIn();

// Get current user
final user = await authService.getCurrentUser();

// Logout
await authService.logout();
```

#### 2. **ApiClient** (`lib/core/api/api_client.dart`)
- Dio HTTP client with interceptors
- Automatically adds JWT token to requests
- Handles 401 errors and redirects to login

```dart
// Token is automatically added to all requests except /auth/login
final response = await apiClient.get('/clients');
```

#### 3. **NavigationService** (`lib/core/navigation_service.dart`)
- Global navigation from anywhere in the app
- Used by ApiClient to redirect on auth errors

---

## 🛠️ Backend Implementation

### Key Components

#### 1. **AuthModule** (`server/src/modules/auth/`)
- JWT configuration
- Passport strategies
- Login controller

#### 2. **JwtAuthGuard** (Global)
- Applied to all routes via `APP_GUARD`
- Validates JWT tokens
- Respects `@Public()` decorator

#### 3. **Strategies**

**LocalStrategy** - Username/Password validation
```typescript
// Validates user credentials during login
POST /auth/login
```

**JwtStrategy** - Token validation
```typescript
// Validates JWT token from Authorization header
// Checks if user still exists and is active
```

---

## 🔧 Testing the Authentication

### Step 1: Start the Backend

```bash
cd server
npm run start:dev
```

Backend should be running on `http://localhost:3000` (or your configured IP)

### Step 2: Create a Test User

```bash
cd server
./create-test-user.sh
```

This creates a user with:
- **Username**: admin
- **Email**: admin@fms.com  
- **Password**: admin123

### Step 3: Test Login with cURL

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

You should receive a JWT token in the response.

### Step 4: Test Protected Endpoint

```bash
# This should fail with 401
curl http://localhost:3000/clients

# This should succeed
curl http://localhost:3000/clients \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Step 5: Test Mobile App

1. Make sure backend is running
2. Update API base URL in `lib/core/constants/api_config.dart` if needed
3. Run the Flutter app
4. Login with admin/admin123
5. All API calls should now include the JWT token automatically

---

## 🔑 Security Features

### Backend
✅ Passwords hashed with bcrypt  
✅ JWT tokens signed with secret key  
✅ Token expiration (24 hours)  
✅ User active status check  
✅ Global authentication guard  
✅ CORS enabled for mobile app  

### Mobile App
✅ Tokens stored in secure storage (not SharedPreferences)  
✅ Automatic token injection in requests  
✅ Automatic logout on 401 errors  
✅ Session expiration handling  
✅ Clean token removal on logout  

---

## 📝 JWT Token Structure

The JWT token contains:

```json
{
  "username": "admin",
  "sub": 1,           // User ID
  "email": "admin@fms.com",
  "fullName": "System Administrator",
  "iat": 1702137600,  // Issued at
  "exp": 1702224000   // Expires at (24h later)
}
```

---

## 🐛 Troubleshooting

### "401 Unauthorized" on protected routes
- ✅ Check if token is being sent in `Authorization` header
- ✅ Verify token hasn't expired
- ✅ Ensure user account is active

### "Connection timeout" in mobile app
- ✅ Check if backend is running
- ✅ Verify API base URL in `api_config.dart`
- ✅ For physical devices, use your computer's IP address

### Login fails with "Invalid credentials"
- ✅ Verify user exists in database
- ✅ Check password is correct
- ✅ Ensure password hash was created with bcrypt

### Token not being added to requests
- ✅ Check if token is stored: `await authService.getAccessToken()`
- ✅ Verify ApiClient interceptor is working
- ✅ Check console logs for request headers

---

## 📚 Additional Resources

### Backend Files
- `server/src/modules/auth/` - Authentication module
- `server/src/modules/auth/guards/jwt-auth.guard.ts` - JWT guard
- `server/src/modules/auth/strategies/` - Passport strategies
- `server/src/app.module.ts` - Global guard registration

### Mobile App Files
- `lib/services/auth_service.dart` - Auth service
- `lib/core/api/api_client.dart` - HTTP client with interceptors
- `lib/core/navigation_service.dart` - Global navigation
- `lib/screens/auth/login_screen.dart` - Login UI

---

## 🎉 Summary

Your Coal Mining FMS now has:

1. ✅ **Secure JWT authentication** on the backend
2. ✅ **Automatic token management** in the mobile app
3. ✅ **Global authentication guard** protecting all routes
4. ✅ **Session expiration handling** with auto-redirect
5. ✅ **Secure token storage** using flutter_secure_storage
6. ✅ **Clean login/logout flow**

All API calls from the mobile app are now authenticated and will automatically include the JWT token! 🚀
