#!/bin/bash

# Test Audit Tracking - Create and Update with User ID
# This script tests that created_by and modified_by fields are being populated

echo "🧪 Testing Audit Field Population"
echo "=================================="
echo ""

# Step 1: Login and get token
echo "📝 Step 1: Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to login. Response:"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo "✅ Login successful! Token: ${TOKEN:0:20}..."
echo ""

# Step 2: Create a new client with authentication
echo "📝 Step 2: Creating a new client with authenticated user..."
CREATE_RESPONSE=$(curl -s -X POST http://localhost:3000/clients \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Audit Test Client",
    "cnic": "12345-6789012-3",
    "phone": "+92-300-1234567",
    "clientTypeId": 1,
    "siteId": 1
  }')

CLIENT_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')

echo "Response:"
echo "$CREATE_RESPONSE" | jq '.' 2>/dev/null || echo "$CREATE_RESPONSE"
echo ""

if [ -z "$CLIENT_ID" ]; then
  echo "❌ Failed to create client"
  exit 1
fi

echo "✅ Client created with ID: $CLIENT_ID"
echo ""

# Step 3: Get the client and check audit fields
echo "📝 Step 3: Fetching client to verify audit fields..."
GET_RESPONSE=$(curl -s -X GET "http://localhost:3000/clients/$CLIENT_ID" \
  -H "Authorization: Bearer $TOKEN")

echo "Response:"
echo "$GET_RESPONSE" | jq '.' 2>/dev/null || echo "$GET_RESPONSE"
echo ""

CREATED_BY=$(echo $GET_RESPONSE | grep -o '"createdById":[0-9]*' | sed 's/"createdById"://')
MODIFIED_BY=$(echo $GET_RESPONSE | grep -o '"modifiedById":[0-9]*' | sed 's/"modifiedById"://')

echo "🔍 Audit Field Values:"
echo "   created_by: $CREATED_BY"
echo "   modified_by: $MODIFIED_BY"
echo ""

if [ "$CREATED_BY" = "1" ] && [ "$MODIFIED_BY" = "1" ]; then
  echo "✅ CREATE: Audit fields populated correctly! ✨"
else
  echo "❌ CREATE: Audit fields NOT populated!"
  echo "   Expected created_by=1, got: $CREATED_BY"
  echo "   Expected modified_by=1, got: $MODIFIED_BY"
fi
echo ""

# Step 4: Update the client
echo "📝 Step 4: Updating the client..."
UPDATE_RESPONSE=$(curl -s -X PATCH "http://localhost:3000/clients/$CLIENT_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Audit Test Client (Updated)",
    "phone": "+92-300-9999999"
  }')

echo "Response:"
echo "$UPDATE_RESPONSE" | jq '.' 2>/dev/null || echo "$UPDATE_RESPONSE"
echo ""

# Step 5: Get the updated client and check modified_by
echo "📝 Step 5: Fetching updated client to verify modified_by..."
GET_UPDATED=$(curl -s -X GET "http://localhost:3000/clients/$CLIENT_ID" \
  -H "Authorization: Bearer $TOKEN")

MODIFIED_BY_AFTER=$(echo $GET_UPDATED | grep -o '"modifiedById":[0-9]*' | sed 's/"modifiedById"://')

echo "🔍 After Update:"
echo "   modified_by: $MODIFIED_BY_AFTER"
echo ""

if [ "$MODIFIED_BY_AFTER" = "1" ]; then
  echo "✅ UPDATE: modified_by field updated correctly! ✨"
else
  echo "❌ UPDATE: modified_by field NOT updated!"
  echo "   Expected modified_by=1, got: $MODIFIED_BY_AFTER"
fi
echo ""

# Step 6: Verify in database
echo "📝 Step 6: Checking database directly..."
DB_RESULT=$(psql -h localhost -U postgres -d miningdb -c "
  SELECT id, name, created_by, modified_by, created_at, modified_at 
  FROM coal_mining.clients 
  WHERE id = $CLIENT_ID;" -t 2>/dev/null)

if [ -n "$DB_RESULT" ]; then
  echo "Database record:"
  echo "$DB_RESULT"
else
  echo "⚠️  Could not connect to database (this is optional check)"
fi
echo ""

# Summary
echo "=================================="
echo "📊 Test Summary:"
echo "=================================="
if [ "$CREATED_BY" = "1" ] && [ "$MODIFIED_BY" = "1" ] && [ "$MODIFIED_BY_AFTER" = "1" ]; then
  echo "✅ All audit tracking tests PASSED! 🎉"
  echo "   - created_by populated on CREATE"
  echo "   - modified_by populated on CREATE"
  echo "   - modified_by updated on UPDATE"
else
  echo "❌ Some tests FAILED"
  [ "$CREATED_BY" != "1" ] && echo "   - created_by NOT populated on CREATE"
  [ "$MODIFIED_BY" != "1" ] && echo "   - modified_by NOT populated on CREATE"
  [ "$MODIFIED_BY_AFTER" != "1" ] && echo "   - modified_by NOT updated on UPDATE"
fi
echo ""

# Cleanup (optional)
read -p "Do you want to delete the test client? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  curl -s -X DELETE "http://localhost:3000/clients/$CLIENT_ID" \
    -H "Authorization: Bearer $TOKEN" > /dev/null
  echo "✅ Test client deleted"
fi
