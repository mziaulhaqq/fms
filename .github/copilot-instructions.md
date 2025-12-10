# NestJS Coal Mining Management System

## Project Overview
This is a full-stack Coal Mining FMS (Financial Management System) with:
- **Backend**: NestJS API with PostgreSQL database
- **Mobile App**: Flutter mobile application
- **Authentication**: JWT-based authentication with secure token storage

## Database
- **Database**: miningdb
- **Schema**: coal_mining
- **ORM**: TypeORM

## Project Status
- ✅ Project scaffolding completed
- ✅ TypeORM configured with existing database
- ✅ Entities created for all tables
- ✅ CRUD endpoints implemented for all entities
- ✅ Swagger documentation added
- ✅ Migrations created for new tables (equipment, production)
- ✅ Migration created to rename labor table to workers
- ✅ **JWT Authentication implemented** (Backend + Mobile)
- ✅ **Global authentication guard** protecting all API routes
- ✅ **Secure token storage** in mobile app (flutter_secure_storage)
- ✅ **Automatic token injection** in API requests
- ✅ **401 error handling** with auto-redirect to login
- ✅ Project builds successfully

## Getting Started

### Backend Setup

1. Configure your database credentials in `.env`
2. Run `npm install` to install dependencies
3. Run `npm run build` to build the project
4. Run `npm run migration:run` to execute migrations
5. Run `npm run start:dev` to start development server
6. Create a test user: `./create-test-user.sh`
7. Test authentication: `./test-auth.sh`
8. Visit `http://localhost:3000/api` for Swagger documentation

### Mobile App Setup

1. Install dependencies: `flutter pub get`
2. Update API base URL in `lib/core/constants/api_config.dart` if needed
3. Run the app: `flutter run`
4. Login with username: `admin` / password: `admin123`

## Authentication

See [AUTHENTICATION.md](../AUTHENTICATION.md) for complete documentation on:
- JWT authentication flow
- Token management
- Security features
- Testing guide
- Troubleshooting

### Quick Test
```bash
# Create test user
cd server
./create-test-user.sh

# Test authentication flow
./test-auth.sh
```

## Next Steps
- ✅ ~~Implement authentication and authorization~~ **DONE**
- Add role-based access control (RBAC)
- Add pagination, filtering, and sorting
- Add comprehensive testing
- Implement logging and monitoring
- Add refresh token mechanism

