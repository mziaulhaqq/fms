#!/bin/bash

# Script to quickly create roles and assign admin role to testuser via database
# Run this when server is not running

echo "🔐 Setting up roles directly in database..."

# Database connection details
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="miningdb"
DB_USER="postgres"
DB_SCHEMA="coal_mining"

echo ""
echo "1️⃣  Creating 'admin' role..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << EOF
INSERT INTO ${DB_SCHEMA}.user_roles (name, description, is_active, created_at, updated_at)
VALUES ('admin', 'Administrator with full access to all resources', true, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;
EOF

echo ""
echo "2️⃣  Creating 'supervisor' role..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << EOF
INSERT INTO ${DB_SCHEMA}.user_roles (name, description, is_active, created_at, updated_at)
VALUES ('supervisor', 'Supervisor with limited access', true, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;
EOF

echo ""
echo "3️⃣  Assigning admin role to testuser..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << EOF
INSERT INTO ${DB_SCHEMA}.user_assigned_roles (user_id, role_id, assigned_at, status, updated_at)
SELECT u.id, r.id, NOW(), 'active', NOW()
FROM ${DB_SCHEMA}.users u, ${DB_SCHEMA}.user_roles r
WHERE u.username = 'testuser' AND r.name = 'admin'
ON CONFLICT (user_id, role_id) DO NOTHING;
EOF

echo ""
echo "4️⃣  Verifying setup..."
echo ""
echo "   📋 Roles:"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << EOF
SELECT id, name, description, is_active FROM ${DB_SCHEMA}.user_roles ORDER BY id;
EOF

echo ""
echo "   👤 User roles:"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << EOF
SELECT 
  u.id, 
  u.username, 
  r.name as role_name,
  uar.status
FROM ${DB_SCHEMA}.user_assigned_roles uar
JOIN ${DB_SCHEMA}.users u ON uar.user_id = u.id
JOIN ${DB_SCHEMA}.user_roles r ON uar.role_id = r.id
WHERE u.username = 'testuser';
EOF

echo ""
echo "✅ Role setup complete!"
echo ""
echo "Now you can:"
echo "  1. Start the server: npm run start:dev"
echo "  2. Login with testuser/test123"
echo "  3. Access admin-only endpoints: /users, /partners, /income, /mining-sites, /profit-distributions"
