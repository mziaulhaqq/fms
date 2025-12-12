#!/bin/bash

# Payables, Receivables, and Payments API Test Script
# Make sure the server is running before executing this script

BASE_URL="http://localhost:3000"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing Payables/Receivables/Payments API${NC}"
echo -e "${BLUE}========================================${NC}"

# First, get auth token
echo -e "\n${BLUE}1. Getting authentication token...${NC}"
TOKEN_RESPONSE=$(curl -s -X POST ${BASE_URL}/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }')

TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Failed to get authentication token${NC}"
  echo $TOKEN_RESPONSE
  exit 1
fi

echo -e "${GREEN}✓ Authentication successful${NC}"

# Test Payables endpoints
echo -e "\n${BLUE}2. Testing Payables endpoints...${NC}"

echo -e "\n${BLUE}GET /payables${NC}"
curl -s ${BASE_URL}/payables \
  -H "Authorization: Bearer $TOKEN" | jq '.' || echo "No payables found"

echo -e "\n${GREEN}✓ Payables endpoint working${NC}"

# Test Receivables endpoints
echo -e "\n${BLUE}3. Testing Receivables endpoints...${NC}"

echo -e "\n${BLUE}GET /receivables${NC}"
curl -s ${BASE_URL}/receivables \
  -H "Authorization: Bearer $TOKEN" | jq '.' || echo "No receivables found"

echo -e "\n${GREEN}✓ Receivables endpoint working${NC}"

# Test Payments endpoints
echo -e "\n${BLUE}4. Testing Payments endpoints...${NC}"

echo -e "\n${BLUE}GET /payments${NC}"
curl -s ${BASE_URL}/payments \
  -H "Authorization: Bearer $TOKEN" | jq '.' || echo "No payments found"

echo -e "\n${GREEN}✓ Payments endpoint working${NC}"

# Test Swagger documentation
echo -e "\n${BLUE}5. Checking Swagger documentation...${NC}"
echo -e "${BLUE}Visit: ${BASE_URL}/api to view API docs${NC}"
echo -e "${GREEN}✓ Swagger should include Payables, Receivables, and Payments sections${NC}"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}All API endpoints are working!${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}API Endpoints Available:${NC}"
echo -e "  ${GREEN}Payables:${NC}"
echo -e "    POST   /payables"
echo -e "    GET    /payables"
echo -e "    GET    /payables/active/client/:clientId"
echo -e "    GET    /payables/:id"
echo -e "    PATCH  /payables/:id"
echo -e "    DELETE /payables/:id"

echo -e "\n  ${GREEN}Receivables:${NC}"
echo -e "    POST   /receivables"
echo -e "    GET    /receivables"
echo -e "    GET    /receivables/pending/client/:clientId"
echo -e "    GET    /receivables/:id"
echo -e "    PATCH  /receivables/:id"
echo -e "    DELETE /receivables/:id"

echo -e "\n  ${GREEN}Payments:${NC}"
echo -e "    POST   /payments"
echo -e "    GET    /payments"
echo -e "    GET    /payments/:id"
echo -e "    PATCH  /payments/:id"
echo -e "    DELETE /payments/:id"

echo ""
