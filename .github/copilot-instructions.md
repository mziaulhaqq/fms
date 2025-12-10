# NestJS Coal Mining Management System

## Project Overview
This is a NestJS API project for managing coal mining operations with PostgreSQL database.

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
- ✅ Project builds successfully

## Getting Started

1. Configure your database credentials in `.env`
2. Run `npm install` to install dependencies
3. Run `npm run build` to build the project
4. Run `npm run migration:run` to execute migrations
5. Run `npm run start:dev` to start development server
6. Visit `http://localhost:3000/api` for Swagger documentation

## Next Steps
- Implement authentication and authorization
- Add pagination, filtering, and sorting
- Add comprehensive testing
- Implement logging and monitoring

