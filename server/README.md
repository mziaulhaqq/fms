# Coal Mining Management System - API<p align="center">

  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>

A comprehensive NestJS-based REST API for managing coal mining operations, including sites, workers, equipment, production tracking, financials, and more.</p>



## 🚀 Features[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456

[circleci-url]: https://circleci.com/gh/nestjs/nest

- **Complete CRUD Operations** for all entities

- **TypeORM Integration** with PostgreSQL  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>

- **Database Migrations** support    <p align="center">

- **Swagger/OpenAPI Documentation**<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>

- **Input Validation** using class-validator<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>

- **Modular Architecture**<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>

- **Existing Database Support**<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>

<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>

## 📋 Table of Contents<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>

<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>

- [Prerequisites](#prerequisites)  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>

- [Installation](#installation)    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>

- [Database Setup](#database-setup)  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>

- [Running Migrations](#running-migrations)</p>

- [Running the Application](#running-the-application)  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)

- [API Documentation](#api-documentation)  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

- [Project Structure](#project-structure)

- [Available Endpoints](#available-endpoints)## Description

- [Development](#development)

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## 🔧 Prerequisites

## Project setup

- Node.js (v18 or higher)

- PostgreSQL (v13 or higher)```bash

- npm or yarn$ npm install

```

## 📦 Installation

## Compile and run the project

1. Clone the repository:

```bash```bash

git clone <your-repo-url># development

cd fms$ npm run start

```

# watch mode

2. Install dependencies:$ npm run start:dev

```bash

npm install# production mode

```$ npm run start:prod

```

3. Configure environment variables:

```bash## Run tests

cp .env.example .env

``````bash

# unit tests

4. Update `.env` file with your database credentials:$ npm run test

```env

# Database Configuration# e2e tests

DB_HOST=localhost$ npm run test:e2e

DB_PORT=5432

DB_USERNAME=postgres# test coverage

DB_PASSWORD=your_password$ npm run test:cov

DB_DATABASE=miningdb```

DB_SCHEMA=coal_mining

## Deployment

# Application Configuration

PORT=3000When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

NODE_ENV=development

```If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:



## 🗄️ Database Setup```bash

$ npm install -g @nestjs/mau

This project connects to an existing PostgreSQL database called `miningdb` with schema `coal_mining`.$ mau deploy

```

### Database Schema

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

The system manages the following entities:

## Resources

#### Core Entities (Existing)

- **clients** - Client information and contactsCheck out a few resources that may come in handy when working with NestJS:

- **mining_sites** - Mining site locations and details

- **partners** - Business partners and stakeholders- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.

- **expenses** - Expense tracking- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).

- **expense_categories** - Expense categorization- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).

- **income** - Income/revenue tracking- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.

- **labor** (renamed to **workers**) - Worker information- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).

- **labor_costs** - Labor cost tracking- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).

- **labor_cost_workers** - Worker-cost relationships- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).

- **partner_payouts** - Partner payment tracking- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

- **profit_distributions** - Profit sharing records

- **site_supervisors** - Site supervisor assignments## Support

- **truck_deliveries** - Delivery tracking

- **users** - System usersNest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

- **user_roles** - User role definitions

- **user_assigned_roles** - User-role assignments## Stay in touch



#### New Entities (via Migrations)- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)

- **equipment** - Mining equipment tracking- Website - [https://nestjs.com](https://nestjs.com/)

- **production** - Daily production records- Twitter - [@nestframework](https://twitter.com/nestframework)



## 🔄 Running Migrations## License



The project includes migrations for:Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).

1. Creating the **equipment** table
2. Creating the **production** table
3. Renaming the **labor** table to **workers**

### Run migrations:

```bash
# Build the project first
npm run build

# Run all pending migrations
npm run migration:run

# Revert last migration (if needed)
npm run migration:revert
```

### Create a new migration:

```bash
# Create empty migration
npm run migration:create -- src/migrations/YourMigrationName

# Generate migration from entity changes
npm run migration:generate -- src/migrations/YourMigrationName
```

## 🏃 Running the Application

### Development mode (with auto-reload):
```bash
npm run start:dev
```

### Production mode:
```bash
npm run build
npm run start:prod
```

### Debug mode:
```bash
npm run start:debug
```

The API will be available at `http://localhost:3000`

## 📚 API Documentation

Once the application is running, access the Swagger documentation at:

```
http://localhost:3000/api
```

The Swagger UI provides:
- Interactive API testing
- Request/response schemas
- Endpoint descriptions
- Example payloads

## 📁 Project Structure

```
fms/
├── src/
│   ├── config/              # Configuration files
│   │   └── typeorm.config.ts
│   ├── entities/            # TypeORM entities
│   │   ├── client.entity.ts
│   │   ├── mining-site.entity.ts
│   │   ├── equipment.entity.ts
│   │   └── ...
│   ├── migrations/          # Database migrations
│   │   ├── 1733846400000-CreateEquipmentTable.ts
│   │   ├── 1733846500000-CreateProductionTable.ts
│   │   └── 1733846600000-RenameLaborToWorkers.ts
│   ├── modules/            # Feature modules
│   │   ├── clients/
│   │   │   ├── dto/
│   │   │   ├── clients.controller.ts
│   │   │   ├── clients.service.ts
│   │   │   └── clients.module.ts
│   │   ├── mining-sites/
│   │   ├── equipment/
│   │   └── ...
│   ├── app.module.ts       # Root module
│   ├── main.ts             # Application entry point
│   └── data-source.ts      # TypeORM data source
├── .env                    # Environment variables
├── .env.example            # Environment template
├── package.json
└── README.md
```

## 🌐 Available Endpoints

All endpoints follow RESTful conventions:

### Clients
- `GET /clients` - Get all clients
- `GET /clients/:id` - Get client by ID
- `POST /clients` - Create new client
- `PATCH /clients/:id` - Update client
- `DELETE /clients/:id` - Delete client

### Mining Sites
- `GET /mining-sites` - Get all mining sites
- `GET /mining-sites/:id` - Get mining site by ID
- `POST /mining-sites` - Create new mining site
- `PATCH /mining-sites/:id` - Update mining site
- `DELETE /mining-sites/:id` - Delete mining site

### Equipment (New)
- `GET /equipment` - Get all equipment
- `GET /equipment/:id` - Get equipment by ID
- `POST /equipment` - Create new equipment
- `PATCH /equipment/:id` - Update equipment
- `DELETE /equipment/:id` - Delete equipment

### Production (New)
- `GET /production` - Get all production records
- `GET /production/:id` - Get production record by ID
- `POST /production` - Create new production record
- `PATCH /production/:id` - Update production record
- `DELETE /production/:id` - Delete production record

### Workers (renamed from Labor)
- `GET /workers` - Get all workers
- `GET /workers/:id` - Get worker by ID
- `POST /workers` - Create new worker
- `PATCH /workers/:id` - Update worker
- `DELETE /workers/:id` - Delete worker

### Other Modules
Similar CRUD endpoints are available for:
- `/partners` - Partners
- `/expenses` - Expenses
- `/expense-categories` - Expense Categories
- `/income` - Income
- `/labor-costs` - Labor Costs
- `/labor-cost-workers` - Labor Cost Workers
- `/partner-payouts` - Partner Payouts
- `/profit-distributions` - Profit Distributions
- `/site-supervisors` - Site Supervisors
- `/truck-deliveries` - Truck Deliveries
- `/users` - Users
- `/user-roles` - User Roles
- `/user-assigned-roles` - User Assigned Roles

## 🛠️ Development

### Running Tests
```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### Linting
```bash
npm run lint
```

### Code Formatting
```bash
npm run format
```

## 🔐 Authentication

Authentication is **not yet implemented** in this version. All endpoints are currently public. Authentication will be added in a future phase.

## 📝 DTOs and Validation

All DTOs are auto-validated using `class-validator`. Check the Swagger documentation for required fields and validation rules for each endpoint.

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## 📄 License

UNLICENSED - Private project

## 🆘 Support

For issues or questions, please refer to the Swagger documentation or contact the development team.

## 🚧 Future Enhancements

- [ ] Implement authentication & authorization
- [ ] Add role-based access control (RBAC)
- [ ] Implement pagination for list endpoints
- [ ] Add filtering and sorting capabilities
- [ ] Create comprehensive test suite
- [ ] Add logging and monitoring
- [ ] Implement caching strategies
- [ ] Add data export functionality
- [ ] Create dashboard endpoints
- [ ] Implement real-time notifications

---

**Built with ❤️ using NestJS and TypeORM**
