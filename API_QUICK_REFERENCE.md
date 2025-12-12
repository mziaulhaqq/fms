# API Quick Reference - Payables/Receivables/Payments

## Authentication
All endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer YOUR_JWT_TOKEN
```

Get token:
```bash
POST /auth/login
{
  "username": "admin",
  "password": "admin123"
}
```

---

## Payables API

### Create Payable (Client pays advance)
```bash
POST /payables
{
  "clientId": 1,
  "miningSiteId": 2,
  "date": "2024-01-15",
  "totalAmount": 10000,
  "description": "Advance payment for coal delivery",
  "proof": ["receipt_001.jpg"]  // Optional
}
```

### Get All Payables
```bash
GET /payables
GET /payables?clientId=1
GET /payables?miningSiteId=2
```

### Get Active Payables for Client
```bash
GET /payables/active/client/:clientId
```

### Get Payable by ID
```bash
GET /payables/:id
```

### Update Payable
```bash
PATCH /payables/:id
{
  "description": "Updated description",
  "remainingBalance": 5000  // Manual adjustment if needed
}
```

### Delete Payable
```bash
DELETE /payables/:id
```

---

## Receivables API

### Create Receivable (Client owes us money)
```bash
POST /receivables
{
  "clientId": 1,
  "miningSiteId": 2,
  "date": "2024-01-15",
  "totalAmount": 5000,
  "description": "Coal delivery - 100 tons, payment in 30 days"
}
```

### Get All Receivables
```bash
GET /receivables
GET /receivables?clientId=1
GET /receivables?miningSiteId=2
```

### Get Pending Receivables for Client
```bash
GET /receivables/pending/client/:clientId
```

### Get Receivable by ID
```bash
GET /receivables/:id
```

### Update Receivable
```bash
PATCH /receivables/:id
{
  "description": "Updated description",
  "remainingBalance": 3000  // Manual adjustment if needed
}
```

### Delete Receivable
```bash
DELETE /receivables/:id
```

---

## Payments API

### Record Payment - Payable Deduction
```bash
POST /payments
{
  "clientId": 1,
  "miningSiteId": 2,
  "paymentType": "Payable Deduction",
  "amount": 3000,
  "paymentDate": "2024-01-20",
  "paymentMethod": "Advance Balance",
  "payableId": 1,
  "receivedBy": "John Doe",
  "notes": "Deduction for 50 tons coal delivery",
  "proof": ["receipt_001.jpg"]  // Optional
}
```

### Record Payment - Receivable Payment
```bash
POST /payments
{
  "clientId": 1,
  "miningSiteId": 2,
  "paymentType": "Receivable Payment",
  "amount": 2000,
  "paymentDate": "2024-01-25",
  "paymentMethod": "Cash",
  "receivableId": 1,
  "receivedBy": "Accountant Name",
  "notes": "Partial payment",
  "proof": ["receipt_002.jpg", "receipt_003.jpg"]  // Optional
}
```

### Get All Payments
```bash
GET /payments
GET /payments?clientId=1
GET /payments?miningSiteId=2
GET /payments?type=Payable+Deduction
GET /payments?type=Receivable+Payment
```

### Get Payment by ID
```bash
GET /payments/:id
```

### Update Payment
```bash
PATCH /payments/:id
{
  "notes": "Updated notes",
  "receivedBy": "Different person"
}
```

### Delete Payment
```bash
DELETE /payments/:id
```

---

## Common Response Formats

### Success - Payable
```json
{
  "id": 1,
  "type": "Advance Payment",
  "clientId": 1,
  "miningSiteId": 2,
  "date": "2024-01-15",
  "description": "Advance payment",
  "totalAmount": "10000.00",
  "remainingBalance": "7000.00",
  "status": "Partially Used",
  "proof": ["receipt_001.jpg"],
  "createdAt": "2024-01-15T10:00:00.000Z",
  "createdById": 1,
  "modifiedAt": "2024-01-20T15:30:00.000Z",
  "modifiedById": 1,
  "client": { ... },
  "miningSite": { ... }
}
```

### Success - Receivable
```json
{
  "id": 1,
  "clientId": 1,
  "miningSiteId": 2,
  "date": "2024-01-15",
  "description": "Coal delivery - 100 tons",
  "totalAmount": "5000.00",
  "remainingBalance": "3000.00",
  "status": "Partially Paid",
  "createdAt": "2024-01-15T10:00:00.000Z",
  "createdById": 1,
  "modifiedAt": "2024-01-25T14:20:00.000Z",
  "modifiedById": 1,
  "client": { ... },
  "miningSite": { ... }
}
```

### Success - Payment
```json
{
  "id": 1,
  "clientId": 1,
  "miningSiteId": 2,
  "paymentType": "Receivable Payment",
  "amount": "2000.00",
  "paymentDate": "2024-01-25",
  "paymentMethod": "Cash",
  "proof": ["receipt_002.jpg"],
  "receivedBy": "Accountant Name",
  "notes": "Partial payment",
  "createdAt": "2024-01-25T14:20:00.000Z",
  "createdBy": 1,
  "client": { ... },
  "miningSite": { ... },
  "creator": { ... }
}
```

### Error Response
```json
{
  "statusCode": 400,
  "message": "Payment amount ($3000) exceeds payable remaining balance ($2000)",
  "error": "Bad Request"
}
```

---

## Status Values

### Payable Status
- `Active` - Has unused balance
- `Partially Used` - Some balance used
- `Fully Used` - All balance consumed

### Receivable Status
- `Pending` - No payment received yet
- `Partially Paid` - Some payment received
- `Fully Paid` - Fully settled

### Payment Types
- `Payable Deduction` - Using client's advance payment
- `Receivable Payment` - Client paying off debt

---

## Validation Rules

### Payables
- `clientId` - Required, must be valid client
- `miningSiteId` - Required, must be valid mining site
- `date` - Required, ISO date string
- `totalAmount` - Required, positive number
- `type` - Always "Advance Payment"

### Receivables
- `clientId` - Required, must be valid client
- `miningSiteId` - Required, must be valid mining site
- `date` - Required, ISO date string
- `totalAmount` - Required, positive number

### Payments
- `clientId` - Required, must be valid client
- `miningSiteId` - Required, must be valid mining site
- `paymentType` - Required, must be "Payable Deduction" or "Receivable Payment"
- `amount` - Required, positive number, cannot exceed remaining balance
- `paymentDate` - Required, ISO date string
- `payableId` - Required if paymentType is "Payable Deduction"
- `receivableId` - Required if paymentType is "Receivable Payment"

---

## Example Workflow

### 1. Client Pays Advance ($10,000)
```bash
POST /payables
{
  "clientId": 1,
  "miningSiteId": 2,
  "date": "2024-01-01",
  "totalAmount": 10000,
  "description": "Advance for January deliveries"
}
```
Result: Payable with `remainingBalance: 10000`, `status: Active`

### 2. First Delivery (Use $3,000 from advance)
```bash
POST /payments
{
  "clientId": 1,
  "miningSiteId": 2,
  "paymentType": "Payable Deduction",
  "amount": 3000,
  "paymentDate": "2024-01-10",
  "payableId": 1,
  "notes": "50 tons coal delivery"
}
```
Result: Payable updated to `remainingBalance: 7000`, `status: Partially Used`

### 3. Second Delivery (Use $7,000 from advance)
```bash
POST /payments
{
  "clientId": 1,
  "miningSiteId": 2,
  "paymentType": "Payable Deduction",
  "amount": 7000,
  "paymentDate": "2024-01-20",
  "payableId": 1,
  "notes": "120 tons coal delivery"
}
```
Result: Payable updated to `remainingBalance: 0`, `status: Fully Used`

### 4. Deliver on Credit ($5,000)
```bash
POST /receivables
{
  "clientId": 2,
  "miningSiteId": 2,
  "date": "2024-01-15",
  "totalAmount": 5000,
  "description": "100 tons - payment in 30 days"
}
```
Result: Receivable with `remainingBalance: 5000`, `status: Pending`

### 5. Client Pays Partial Amount ($2,000)
```bash
POST /payments
{
  "clientId": 2,
  "miningSiteId": 2,
  "paymentType": "Receivable Payment",
  "amount": 2000,
  "paymentDate": "2024-02-01",
  "paymentMethod": "Bank Transfer",
  "receivableId": 1,
  "receivedBy": "Accountant"
}
```
Result: Receivable updated to `remainingBalance: 3000`, `status: Partially Paid`

### 6. Client Pays Remaining ($3,000)
```bash
POST /payments
{
  "clientId": 2,
  "miningSiteId": 2,
  "paymentType": "Receivable Payment",
  "amount": 3000,
  "paymentDate": "2024-02-15",
  "paymentMethod": "Cash",
  "receivableId": 1,
  "receivedBy": "Accountant"
}
```
Result: Receivable updated to `remainingBalance: 0`, `status: Fully Paid`

---

## Testing with cURL

### Complete Test Script
```bash
#!/bin/bash

# Get auth token
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' \
  | jq -r '.access_token')

# Create a payable
curl -X POST http://localhost:3000/payables \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": 1,
    "miningSiteId": 2,
    "date": "2024-01-15",
    "totalAmount": 10000,
    "description": "Test advance payment"
  }' | jq '.'

# Get all payables
curl http://localhost:3000/payables \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Record a payment
curl -X POST http://localhost:3000/payments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": 1,
    "miningSiteId": 2,
    "paymentType": "Payable Deduction",
    "amount": 3000,
    "paymentDate": "2024-01-20",
    "payableId": 1,
    "notes": "Test deduction"
  }' | jq '.'

# Get all payments
curl http://localhost:3000/payments \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

---

## Swagger Documentation

**URL**: http://localhost:3000/api

Navigate to the Swagger UI to:
- View all endpoints
- Test API calls interactively
- See request/response schemas
- Try out authentication
