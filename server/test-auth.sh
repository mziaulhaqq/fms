#!/bin/bash

# Quick test script to verify authentication is working

echo "🧪 Testing Coal Mining FMS Authentication Flow"
echo "================================================"
echo ""

API_URL="http://localhost:3000"

# Test 1: Health check
echo "1️⃣  Testing server connectivity..."
if curl -s -f "$API_URL" > /dev/null 2>&1; then
  echo "   ✅ Server is running"
else
  echo "   ❌ Server is not running or not accessible"
  echo "   💡 Start the server with: cd server && npm run start:dev"
  exit 1
fi
echo ""

# Test 2: Test protected endpoint without auth (should fail)
echo "2️⃣  Testing protected endpoint without authentication..."
response=$(curl -s -w "\n%{http_code}" "$API_URL/clients")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" = "401" ]; then
  echo "   ✅ Protected endpoint correctly returns 401 Unauthorized"
else
  echo "   ⚠️  Expected 401, got $status_code"
fi
echo ""

# Test 3: Login and get token
echo "3️⃣  Testing login endpoint..."
login_response=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

# Check if login was successful
if echo "$login_response" | grep -q "access_token"; then
  echo "   ✅ Login successful"
  
  # Extract token (requires jq, or we'll use grep)
  token=$(echo "$login_response" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
  
  if [ -n "$token" ]; then
    echo "   ✅ JWT token received"
    echo ""
    
    # Test 4: Access protected endpoint with token
    echo "4️⃣  Testing protected endpoint with authentication..."
    auth_response=$(curl -s -w "\n%{http_code}" "$API_URL/clients" \
      -H "Authorization: Bearer $token")
    auth_status=$(echo "$auth_response" | tail -n1)
    
    if [ "$auth_status" = "200" ]; then
      echo "   ✅ Protected endpoint accessible with token"
      echo ""
      echo "🎉 All tests passed!"
      echo ""
      echo "Your authentication is working correctly! 🚀"
      echo ""
      echo "Next steps:"
      echo "  1. Start the Flutter app"
      echo "  2. Login with username: admin, password: admin123"
      echo "  3. All API calls will now be authenticated automatically!"
    else
      echo "   ❌ Failed to access protected endpoint (Status: $auth_status)"
    fi
  else
    echo "   ❌ Could not extract token from response"
  fi
else
  echo "   ❌ Login failed"
  echo "   Response: $login_response"
  echo ""
  echo "   💡 Make sure you've created a test user:"
  echo "   ./create-test-user.sh"
fi

echo ""
