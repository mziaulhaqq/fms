#!/bin/bash

# Test script to verify audit fields (created_by, modified_by) are populated
# for client-types, account-types, and expense-types

BASE_URL="http://localhost:3000"
USERNAME="admin"
PASSWORD="admin123"

echo "🔐 Step 1: Login to get JWT token..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}")

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed!"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo "✅ Login successful! Token obtained."
echo ""

# Test Client Type
echo "📝 Step 2: Creating a test client type..."
CLIENT_TYPE_RESPONSE=$(curl -s -X POST "${BASE_URL}/client-types" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "typeName": "Test Client Type Audit",
    "description": "Testing audit fields",
    "isActive": true
  }')

CLIENT_TYPE_ID=$(echo "$CLIENT_TYPE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$CLIENT_TYPE_ID" ]; then
  echo "❌ Client type creation failed!"
  echo "$CLIENT_TYPE_RESPONSE"
else
  echo "✅ Client type created with ID: $CLIENT_TYPE_ID"
  
  # Check database for audit fields
  echo ""
  echo "🔍 Checking database for client type audit fields..."
  PGPASSWORD=ziaul12345 psql -h localhost -U postgres -d miningdb -c \
    "SELECT id, type_name, created_by, modified_by, created_at, modified_at FROM coal_mining.client_types WHERE id = $CLIENT_TYPE_ID;"
fi

echo ""
echo "---"
echo ""

# Test Account Type
echo "📝 Step 3: Creating a test account type..."
ACCOUNT_TYPE_RESPONSE=$(curl -s -X POST "${BASE_URL}/account-types" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "typeName": "Test Account Type Audit",
    "description": "Testing audit fields",
    "isActive": true
  }')

ACCOUNT_TYPE_ID=$(echo "$ACCOUNT_TYPE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$ACCOUNT_TYPE_ID" ]; then
  echo "❌ Account type creation failed!"
  echo "$ACCOUNT_TYPE_RESPONSE"
else
  echo "✅ Account type created with ID: $ACCOUNT_TYPE_ID"
  
  # Check database for audit fields
  echo ""
  echo "🔍 Checking database for account type audit fields..."
  PGPASSWORD=ziaul12345 psql -h localhost -U postgres -d miningdb -c \
    "SELECT id, type_name, created_by, modified_by, created_at, modified_at FROM coal_mining.account_types WHERE id = $ACCOUNT_TYPE_ID;"
fi

echo ""
echo "---"
echo ""

# Test Expense Type
echo "📝 Step 4: Creating a test expense type..."
EXPENSE_TYPE_RESPONSE=$(curl -s -X POST "${BASE_URL}/expense-types" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "typeName": "Test Expense Type Audit",
    "description": "Testing audit fields",
    "isActive": true
  }')

EXPENSE_TYPE_ID=$(echo "$EXPENSE_TYPE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$EXPENSE_TYPE_ID" ]; then
  echo "❌ Expense type creation failed!"
  echo "$EXPENSE_TYPE_RESPONSE"
else
  echo "✅ Expense type created with ID: $EXPENSE_TYPE_ID"
  
  # Check database for audit fields
  echo ""
  echo "🔍 Checking database for expense type audit fields..."
  PGPASSWORD=ziaul12345 psql -h localhost -U postgres -d miningdb -c \
    "SELECT id, type_name, created_by, modified_by, created_at, modified_at FROM coal_mining.expense_types WHERE id = $EXPENSE_TYPE_ID;"
fi

echo ""
echo "---"
echo ""

# Test Updates
if [ ! -z "$CLIENT_TYPE_ID" ]; then
  echo "📝 Step 5: Updating client type to test modified_by..."
  UPDATE_RESPONSE=$(curl -s -X PATCH "${BASE_URL}/client-types/${CLIENT_TYPE_ID}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
      "description": "Updated description to test audit"
    }')
  
  echo "✅ Client type updated"
  echo ""
  echo "🔍 Checking database after update..."
  PGPASSWORD=ziaul12345 psql -h localhost -U postgres -d miningdb -c \
    "SELECT id, type_name, created_by, modified_by, created_at, modified_at FROM coal_mining.client_types WHERE id = $CLIENT_TYPE_ID;"
fi

echo ""
echo "✅ Test complete! Check the database results above."
echo ""
echo "Expected results:"
echo "  - created_by should be 1 (admin user)"
echo "  - modified_by should be 1 (admin user)"
echo "  - Both should NOT be NULL"
