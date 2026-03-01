#!/bin/bash

# Kill background processes on exit
trap "kill 0" EXIT

# Clean up any zombie processes first
fuser -k 3000/tcp 5173/tcp 5174/tcp 2>/dev/null || true

echo "🚀 Launching Vue + Rails Monorepo..."

# Launch Backend (Rails)
echo "💎 Starting Rails Backend on port 3000..."
cd backend && bin/rails s -p 3000 &
BACKEND_PID=$!

# Launch Client
echo "Starting Client Frontend on port 5173..."
cd ../client && npm run dev &
CLIENT_PID=$!

# Launch Admin
echo "Starting Admin Frontend on port 5174..."
cd ../admin && npm run dev &
ADMIN_PID=$!

echo "All systems running!"
echo "   - Backend: http://localhost:3000"
echo "   - Client:  http://localhost:5173"
echo "   - Admin:   http://localhost:5174"
echo "Press Ctrl+C to stop all services."

# Wait for all background processes
wait
