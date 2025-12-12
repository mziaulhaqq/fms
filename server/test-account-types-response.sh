#!/bin/bash

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
  exit 1
fi

echo "✅ Login successful!"
echo ""

echo "📝 Step 2: Getting account types..."
RESPONSE=$(curl -s -X GET "${BASE_URL}/account-types" \
  -H "Authorization: Bearer $TOKEN")

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool || echo "$RESPONSE"
