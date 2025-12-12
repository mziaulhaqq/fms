#!/bin/bash

BASE_URL="http://localhost:3000"

echo "=== Testing General Ledger Audit Tracking ==="
echo ""

# Step 1: Login
echo "1. Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token')
USER_ID=$(echo $LOGIN_RESPONSE | jq -r '.user.id')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "❌ Login failed!"
  echo "$LOGIN_RESPONSE" | jq .
  exit 1
fi

echo "✅ Login successful. User ID: $USER_ID"
echo ""

# Step 2: Get mining sites
echo "2. Fetching mining sites..."
SITES_RESPONSE=$(curl -s -X GET "$BASE_URL/mining-sites" \
  -H "Authorization: Bearer $TOKEN")

SITE_ID=$(echo $SITES_RESPONSE | jq -r '.[0].id')
SITE_NAME=$(echo $SITES_RESPONSE | jq -r '.[0].name')

if [ "$SITE_ID" = "null" ] || [ -z "$SITE_ID" ]; then
  echo "❌ No mining sites found!"
  exit 1
fi

echo "✅ Using site: $SITE_NAME (ID: $SITE_ID)"
echo ""

# Step 3: Get account types
echo "3. Fetching account types..."
TYPES_RESPONSE=$(curl -s -X GET "$BASE_URL/account-types" \
  -H "Authorization: Bearer $TOKEN")

ACCOUNT_TYPE_ID=$(echo $TYPES_RESPONSE | jq -r '.[0].id')
ACCOUNT_TYPE_NAME=$(echo $TYPES_RESPONSE | jq -r '.[0].name')

if [ "$ACCOUNT_TYPE_ID" = "null" ] || [ -z "$ACCOUNT_TYPE_ID" ]; then
  echo "❌ No account types found!"
  exit 1
fi

echo "✅ Using account type: $ACCOUNT_TYPE_NAME (ID: $ACCOUNT_TYPE_ID)"
echo ""

# Step 4: Create general ledger account
echo "4. Creating general ledger account..."
TIMESTAMP=$(date +%s)
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/general-ledger" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"accountCode\": \"TEST-$TIMESTAMP\",
    \"accountName\": \"Test Account $TIMESTAMP\",
    \"accountTypeId\": $ACCOUNT_TYPE_ID,
    \"miningSiteId\": $SITE_ID,
    \"description\": \"Test audit tracking\",
    \"isActive\": true
  }")

ACCOUNT_ID=$(echo $CREATE_RESPONSE | jq -r '.id')
CREATED_BY=$(echo $CREATE_RESPONSE | jq -r '.createdById')
MODIFIED_BY=$(echo $CREATE_RESPONSE | jq -r '.modifiedById')

echo "Response:"
echo $CREATE_RESPONSE | jq .

if [ "$ACCOUNT_ID" = "null" ] || [ -z "$ACCOUNT_ID" ]; then
  echo "❌ Account creation failed!"
  exit 1
fi

echo ""
echo "=== Audit Field Verification ==="
echo "Created By: $CREATED_BY (Expected: $USER_ID)"
echo "Modified By: $MODIFIED_BY (Expected: $USER_ID)"
echo ""

if [ "$CREATED_BY" = "$USER_ID" ] && [ "$MODIFIED_BY" = "$USER_ID" ]; then
  echo "✅ SUCCESS! Audit fields are correctly populated!"
else
  echo "❌ FAILED! Audit fields are null or incorrect!"
  echo "   createdById: $CREATED_BY (expected: $USER_ID)"
  echo "   modifiedById: $MODIFIED_BY (expected: $USER_ID)"
  exit 1
fi

echo ""

# Step 5: Update the account
echo "5. Updating general ledger account..."
sleep 1
UPDATE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/general-ledger/$ACCOUNT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"accountName\": \"Updated Account $TIMESTAMP\",
    \"description\": \"Updated via audit test\"
  }")

UPDATED_MODIFIED_BY=$(echo $UPDATE_RESPONSE | jq -r '.modifiedById')

echo "Response:"
echo $UPDATE_RESPONSE | jq .
echo ""

if [ "$UPDATED_MODIFIED_BY" = "$USER_ID" ]; then
  echo "✅ SUCCESS! modifiedById updated correctly on update!"
else
  echo "❌ WARNING! modifiedById not updated: $UPDATED_MODIFIED_BY (expected: $USER_ID)"
fi

echo ""
echo "=== Test Complete ==="
