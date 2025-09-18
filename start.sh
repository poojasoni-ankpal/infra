#!/bin/bash
set -e

echo "🚀 Starting Ankpal Docker Environment..."

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created"
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Remove old volumes to ensure clean database setup
echo "🗑️  Removing old database volumes..."
docker volume rm ankpal_postgres_data 2>/dev/null || true

# Start the containers
echo "🐳 Starting containers..."
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to initialize..."
sleep 15

# Check if backend is running
echo "🔍 Checking backend status..."
if docker-compose ps | grep -q "ankpal-backend-dev.*Up"; then
    echo "✅ Backend is running successfully!"
    echo ""
    echo "🌐 Services are now available:"
    echo "   - Development Frontend: http://localhost:8080"
    echo "   - Development Backend: http://localhost:3000"
    echo "   - UAT Frontend: http://localhost:8081"
    echo "   - UAT Backend: http://localhost:3001"
    echo "   - Nginx (Main): http://localhost:80"
    echo ""
    echo "📊 To view logs: docker-compose logs -f"
    echo "🛑 To stop: docker-compose down"
else
    echo "❌ Backend failed to start. Check logs with: docker-compose logs backend-dev"
    exit 1
fi
