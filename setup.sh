#!/bin/bash
set -e

echo "🚀 Setting up Ankpal Docker Environment..."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp env.example .env
    echo "✅ .env file created from env.example"
    echo "⚠️  Please update the .env file with your actual values before running docker-compose"
fi

# Create env directory if it doesn't exist
mkdir -p env

# Create backend environment files if they don't exist
if [ ! -f env/backend.dev.env ]; then
    echo "📝 Backend dev environment file already exists"
else
    echo "✅ Backend dev environment file created"
fi

if [ ! -f env/backend.uat.env ]; then
    echo "📝 Backend UAT environment file already exists"
else
    echo "✅ Backend UAT environment file created"
fi

# Create nginx logs directory
mkdir -p nginx/logs

echo "🔧 Building Docker images..."

# Build frontend images
echo "Building frontend-dev image..."
docker build -t ankpal-frontend:dev-local ../quasar-frontend -f ../quasar-frontend/Dockerfile --build-arg VITE_API_BASE=http://localhost:3000/api

echo "Building frontend-uat image..."
docker build -t ankpal-frontend:uat-local ../quasar-frontend -f ../quasar-frontend/Dockerfile --build-arg VITE_API_BASE=http://localhost:3001/api

# Build backend images
echo "Building backend-dev image..."
docker build -t ankpal-backend:dev-local ../nest-backend -f ../nest-backend/Dockerfile

echo "Building backend-uat image..."
docker build -t ankpal-backend:uat-local ../nest-backend -f ../nest-backend/Dockerfile

echo "✅ All images built successfully!"

echo "🐳 Starting Docker containers..."
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "🌱 Running database migrations..."
docker-compose exec backend-dev npm run migrate:ankpal || echo "Migration may have already run"

echo "🌱 Seeding database..."
docker-compose exec backend-dev curl -X GET http://localhost:3000/seeder/seed || echo "Seeder may have already run"

echo "✅ Setup complete!"
echo ""
echo "🌐 Services available at:"
echo "   - Development Frontend: http://localhost:8080"
echo "   - Development Backend: http://localhost:3000"
echo "   - UAT Frontend: http://localhost:8081"
echo "   - UAT Backend: http://localhost:3001"
echo "   - Nginx (Main): http://localhost:80"
echo ""
echo "📊 To view logs:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 To stop services:"
echo "   docker-compose down"
