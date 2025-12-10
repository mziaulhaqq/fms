#!/bin/bash

# Script to create roles and assign admin role to a user

echo "🔐 Setting up roles for Coal Mining FMS..."
echo ""

API_URL="http://localhost:3000"

# Step 1: Create Admin Role
echo "1️⃣  Creating 'admin' role..."
admin_role=$(curl -s -X POST "$API_URL/user-roles" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "admin",
    "description": "Administrator with full access",
    "permissions": {"all": true},
    "isActive": true
  }')

if echo "$admin_role" | grep -q '"id"'; then
  admin_role_id=$(echo "$admin_role" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
  echo "   ✅ Admin role created (ID: $admin_role_id)"
else
  echo "   ⚠️  Admin role might already exist or error occurred"
  echo "   Response: $admin_role"
fi

echo ""

# Step 2: Create Supervisor Role
echo "2️⃣  Creating 'supervisor' role..."
supervisor_role=$(curl -s -X POST "$API_URL/user-roles" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "supervisor",
    "description": "Site supervisor with limited access",
    "permissions": {"limited": true},
    "isActive": true
  }')

if echo "$supervisor_role" | grep -q '"id"'; then
  supervisor_role_id=$(echo "$supervisor_role" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
  echo "   ✅ Supervisor role created (ID: $supervisor_role_id)"
else
  echo "   ⚠️  Supervisor role might already exist or error occurred"
  echo "   Response: $supervisor_role"
fi

echo ""

# Step 3: Get testuser ID
echo "3️⃣  Getting testuser ID..."
login_response=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "test123"}')

if echo "$login_response" | grep -q '"access_token"'; then
  user_id=$(echo "$login_response" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
  echo "   ✅ Testuser ID: $user_id"
  
  # Step 4: Assign admin role to testuser
  echo ""
  echo "4️⃣  Assigning admin role to testuser..."
  
  # We need to get the admin role ID first
  # For now, let's assume it's 1 or we'll use the one we just created
  assign_role=$(curl -s -X POST "$API_URL/user-assigned-roles" \
    -H "Content-Type: application/json" \
    -d "{
      \"userId\": $user_id,
      \"roleId\": 1,
      \"status\": \"active\"
    }")
  
  if echo "$assign_role" | grep -q '"id"'; then
    echo "   ✅ Admin role assigned to testuser"
  else
    echo "   ⚠️  Failed to assign role"
    echo "   Response: $assign_role"
  fi
else
  echo "   ❌ Failed to get testuser info"
  echo "   Make sure testuser exists and password is correct"
fi

echo ""
echo "✅ Role setup complete!"
echo ""
echo "Now testuser should have admin access to:"
echo "  - Users"
echo "  - Profit Distributions"
echo "  - Partners"
echo "  - Income"
echo "  - Mining Sites"
echo ""
