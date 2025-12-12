#!/bin/bash

echo "🧪 Testing Audit Field Population (Simplified)"
echo "=============================================="
echo ""

# Login
echo "1️⃣  Getting authentication token..."
RESPONSE=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to login"
  echo "Response: $RESPONSE"
  exit 1
fi

echo "✅ Token received: ${TOKEN:0:30}..."
echo ""

# Create client
echo "2️⃣  Creating a new client..."
RESPONSE=$(curl -s -X POST http://localhost:3000/clients \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "businessName": "Audit Test Client",
    "ownerName": "Test Owner",
    "ownerContact": "+92-300-1234567",
    "clientTypeId": 1,
    "siteId": 1
  }')

CLIENT_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')

if [ -z "$CLIENT_ID" ]; then
  echo "❌ Failed to create client"
  echo "Response: $RESPONSE"
  exit 1
fi

echo "✅ Client created with ID: $CLIENT_ID"
echo ""

# Get and check audit fields
echo "3️⃣  Checking audit fields..."
CLIENT=$(curl -s -X GET "http://localhost:3000/clients/$CLIENT_ID" \
  -H "Authorization: Bearer $TOKEN")

CREATED_BY=$(echo "$CLIENT" | grep -o '"createdById":[0-9]*' | sed 's/"createdById"://')
MODIFIED_BY=$(echo "$CLIENT" | grep -o '"modifiedById":[0-9]*' | sed 's/"modifiedById"://')

echo "   createdById: $CREATED_BY"
echo "   modifiedById: $MODIFIED_BY"
echo ""

if [ "$CREATED_BY" = "1" ] && [ "$MODIFIED_BY" = "1" ]; then
  echo "✅ SUCCESS: Audit fields populated correctly! 🎉"
  echo ""
  
  # Clean up
  curl -s -X DELETE "http://localhost:3000/clients/$CLIENT_ID" \
    -H "Authorization: Bearer $TOKEN" > /dev/null
  echo "✅ Test client deleted"
else
  echo "❌ FAILED: Audit fields are NULL or incorrect"
  echo "   Expected: createdById=1, modifiedById=1"
  echo "   Got: createdById=$CREATED_BY, modifiedById=$MODIFIED_BY"
  echo ""
  echo "Full response:"
  echo "$CLIENT"
fi
