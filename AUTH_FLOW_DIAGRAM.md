# Authentication Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    COAL MINING FMS - AUTHENTICATION FLOW                 │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐                                    ┌──────────────────┐
│                  │                                    │                  │
│  Flutter Mobile  │                                    │  NestJS Backend  │
│      App         │                                    │    (Port 3000)   │
│                  │                                    │                  │
└────────┬─────────┘                                    └────────┬─────────┘
         │                                                       │
         │                                                       │
    ┌────▼────┐                                             ┌───▼────┐
    │ Login   │                                             │ Auth   │
    │ Screen  │                                             │ Module │
    └────┬────┘                                             └───┬────┘
         │                                                      │
         │  1. User enters credentials                         │
         │     (username: admin, password: admin123)           │
         │                                                      │
         │  2. POST /auth/login                                │
         ├─────────────────────────────────────────────────────►│
         │     { username: "admin", password: "admin123" }     │
         │                                                      │
         │                                           3. LocalStrategy
         │                                              validates user
         │                                              - Check user exists
         │                                              - Verify password (bcrypt)
         │                                              - Check isActive
         │                                                      │
         │  4. Response with JWT token                         │
         │◄─────────────────────────────────────────────────────┤
         │     {                                                │
         │       "access_token": "eyJhbG...",                   │
         │       "user": { id, username, email, ... }           │
         │     }                                                │
         │                                                      │
    ┌────▼────────────┐                                        │
    │ AuthService     │                                        │
    │ stores token in │                                        │
    │ SecureStorage   │                                        │
    └────┬────────────┘                                        │
         │                                                      │
         │  5. Navigate to Dashboard                           │
         │                                                      │
    ┌────▼────────┐                                            │
    │ Dashboard   │                                            │
    │ Screen      │                                            │
    └────┬────────┘                                            │
         │                                                      │
         │  6. User clicks "Clients" button                    │
         │                                                      │
    ┌────▼────────────┐                                        │
    │ ClientService   │                                        │
    │ getAllClients() │                                        │
    └────┬────────────┘                                        │
         │                                                      │
    ┌────▼─────────┐                                           │
    │  ApiClient   │                                           │
    │ (Dio with    │                                           │
    │ interceptor) │                                           │
    └────┬─────────┘                                           │
         │                                                      │
         │  7. Interceptor adds Authorization header           │
         │     Authorization: Bearer eyJhbG...                 │
         │                                                      │
         │  8. GET /clients                                    │
         ├─────────────────────────────────────────────────────►│
         │     Headers: {                                      │
         │       Authorization: "Bearer eyJhbG..."             │
         │     }                                               │
         │                                               ┌─────▼──────┐
         │                                               │ JwtAuth    │
         │                                               │ Guard      │
         │                                               │ (Global)   │
         │                                               └─────┬──────┘
         │                                                     │
         │                                               9. JwtStrategy
         │                                                  validates token
         │                                                  - Verify signature
         │                                                  - Check expiration
         │                                                  - Get user from DB
         │                                                     │
         │                                              ┌──────▼─────┐
         │                                              │ Clients    │
         │                                              │ Controller │
         │                                              └──────┬─────┘
         │                                                     │
         │  10. Response with client data                     │
         │◄─────────────────────────────────────────────────────┤
         │     [ { id: 1, name: "..." }, ... ]                │
         │                                                      │
    ┌────▼────────┐                                            │
    │ Display     │                                            │
    │ Clients     │                                            │
    │ in UI       │                                            │
    └─────────────┘                                            │
                                                                │
═══════════════════════════════════════════════════════════════════════════
                         TOKEN EXPIRATION / 401 ERROR
═══════════════════════════════════════════════════════════════════════════

    ┌─────────────┐                                            │
    │ Any Request │                                            │
    │ (expired    │                                            │
    │  token)     │                                            │
    └────┬────────┘                                            │
         │                                                      │
         │  11. GET /some-endpoint                             │
         ├─────────────────────────────────────────────────────►│
         │     Authorization: Bearer <expired_token>           │
         │                                                      │
         │                                               ┌─────▼──────┐
         │                                               │ JwtAuth    │
         │                                               │ Guard      │
         │                                               └─────┬──────┘
         │                                                     │
         │                                               Token is invalid
         │                                               or expired
         │                                                     │
         │  12. 401 Unauthorized                              │
         │◄─────────────────────────────────────────────────────┤
         │     { message: "Unauthorized" }                    │
         │                                                      │
    ┌────▼─────────┐                                           │
    │  ApiClient   │                                           │
    │ Interceptor  │                                           │
    │ onError()    │                                           │
    └────┬─────────┘                                           │
         │                                                      │
         │  13. Clear stored tokens                            │
         │      - access_token                                 │
         │      - user_data                                    │
         │                                                      │
         │  14. Navigate to Login                              │
         │      Show: "Session expired"                        │
         │                                                      │
    ┌────▼────┐                                                │
    │ Login   │                                                │
    │ Screen  │                                                │
    └─────────┘                                                │
                                                                │
═══════════════════════════════════════════════════════════════════════════

KEY FEATURES:
✅ All routes protected by default (except @Public())
✅ JWT token automatically added to requests
✅ Secure token storage (flutter_secure_storage)
✅ Automatic redirect to login on 401
✅ 24-hour token expiration
✅ Password hashing with bcrypt
✅ User active status check
```
