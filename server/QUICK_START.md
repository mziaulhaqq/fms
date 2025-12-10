# Quick Start Guide

## Prerequisites Checklist
- [ ] Node.js v18+ installed
- [ ] PostgreSQL installed and running
- [ ] Database `miningdb` exists
- [ ] Schema `coal_mining` exists with existing tables

## Setup Steps

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
Copy `.env.example` to `.env` and update with your credentials:
```bash
cp .env.example .env
```

Edit `.env`:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=your_postgres_username
DB_PASSWORD=your_postgres_password
DB_DATABASE=miningdb
DB_SCHEMA=coal_mining
PORT=3000
NODE_ENV=development
```

### 3. Build the Project
```bash
npm run build
```

### 4. Run Migrations (Optional - for new tables)
This will create:
- `equipment` table
- `production` table
- Rename `labor` table to `workers`

```bash
npm run migration:run
```

### 5. Start the Development Server
```bash
npm run start:dev
```

### 6. Access the API
- **API Base URL**: `http://localhost:3000`
- **Swagger Documentation**: `http://localhost:3000/api`

## Testing the API

### Using Swagger UI
1. Open `http://localhost:3000/api` in your browser
2. Explore available endpoints
3. Click "Try it out" on any endpoint
4. Fill in the required data
5. Click "Execute"

### Using cURL

#### Create a Client
```bash
curl -X POST http://localhost:3000/clients \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ABC Mining Corp",
    "email": "contact@abcmining.com",
    "phone": "+1234567890",
    "type": "corporate"
  }'
```

#### Get All Clients
```bash
curl http://localhost:3000/clients
```

#### Get Client by ID
```bash
curl http://localhost:3000/clients/1
```

#### Update a Client
```bash
curl -X PATCH http://localhost:3000/clients/1 \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+0987654321"
  }'
```

#### Delete a Client
```bash
curl -X DELETE http://localhost:3000/clients/1
```

## Available API Endpoints

All modules follow the same CRUD pattern:

| Module | Endpoint Base | Description |
|--------|---------------|-------------|
| Clients | `/clients` | Client management |
| Mining Sites | `/mining-sites` | Mining site management |
| Partners | `/partners` | Partner management |
| Expenses | `/expenses` | Expense tracking |
| Expense Categories | `/expense-categories` | Expense categorization |
| Income | `/income` | Income tracking |
| Workers | `/workers` | Worker management (formerly labor) |
| Labor Costs | `/labor-costs` | Labor cost tracking |
| Labor Cost Workers | `/labor-cost-workers` | Worker-cost relationships |
| Partner Payouts | `/partner-payouts` | Partner payments |
| Profit Distributions | `/profit-distributions` | Profit sharing |
| Site Supervisors | `/site-supervisors` | Site supervisor assignments |
| Truck Deliveries | `/truck-deliveries` | Delivery tracking |
| Users | `/users` | User management |
| User Roles | `/user-roles` | Role definitions |
| User Assigned Roles | `/user-assigned-roles` | User-role assignments |
| **Equipment** | `/equipment` | Equipment tracking (NEW) |
| **Production** | `/production` | Production records (NEW) |

## Common Operations

### View Database Schema
```bash
psql -U postgres -d miningdb
\dt coal_mining.*
```

### Check Migration Status
```bash
npm run build
npm run typeorm -- migration:show -d src/data-source.ts
```

### Revert Last Migration
```bash
npm run migration:revert
```

## Troubleshooting

### Connection Issues
- Verify PostgreSQL is running
- Check database credentials in `.env`
- Ensure database and schema exist

### Migration Errors
- Build the project first: `npm run build`
- Check if migrations already ran
- Verify database permissions

### Port Already in Use
Change the port in `.env`:
```env
PORT=3001
```

## Next Steps

1. ✅ Basic setup complete
2. 📝 Customize DTOs for each module
3. 🔐 Add authentication (future phase)
4. 🧪 Write tests
5. 📊 Add pagination and filtering
6. 🚀 Deploy to production

## Support

For detailed documentation, see:
- Main README.md
- Swagger UI at `/api`
- TypeORM Documentation: https://typeorm.io
- NestJS Documentation: https://docs.nestjs.com
