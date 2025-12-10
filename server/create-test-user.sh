#!/bin/bash

# Script to create a test user for the Coal Mining FMS

echo "🔑 Creating test user for Coal Mining FMS..."
echo ""

# API endpoint
API_URL="http://localhost:3000/users"

# User data with plain password (will be hashed by the backend)
USER_DATA='{
  "username": "admin",
  "email": "admin@fms.com",
  "password": "admin123",
  "fullName": "System Administrator",
  "phone": "+1234567890",
  "isActive": true
}'

echo "Creating user with credentials:"
echo "  Username: admin"
echo "  Email: admin@fms.com"
echo "  Password: admin123"
echo ""

# Make the request
response=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$USER_DATA")

# Check if successful
if echo "$response" | grep -q '"id"'; then
  echo "✅ User created successfully!"
  echo ""
  echo "You can now login with:"
  echo "  Username/Email: admin or admin@fms.com"
  echo "  Password: admin123"
else
  echo "❌ Failed to create user"
  echo "Response: $response"
  echo ""
  echo "💡 Note: If user already exists, you can still login with the credentials above"
fi

echo ""
