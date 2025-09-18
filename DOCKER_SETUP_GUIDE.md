# Docker Setup Guide for Ankpal

This guide will help you set up the complete Ankpal application using Docker.

## 🚀 Quick Start

### 1. Copy Environment Files
```bash
cd infra
cp env.example .env
```

### 2. Update Environment Variables
Edit the `.env` file with your actual values:
```bash
# Database Configuration
POSTGRES_USER=your_db_user
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=ankpal_db

# Docker Image Names (usually don't need to change)
FRONTEND_DEV_IMAGE=ankpal-frontend:dev-local
BACKEND_DEV_IMAGE=ankpal-backend:dev-local
FRONTEND_UAT_IMAGE=ankpal-frontend:uat-local
BACKEND_UAT_IMAGE=ankpal-backend:uat-local
```

### 3. Update Backend Environment Files
Edit the backend environment files with your actual configuration:
- `env/backend.dev.env` - Development backend configuration
- `env/backend.uat.env` - UAT backend configuration

**Important**: Update these values in both files:
- `JWT_SECRET` - Use a strong secret key
- `AWS_SMTP_ACCESS_KEY` and `AWS_SMTP_SECRET_KEY` - Your AWS credentials
- `S3_ACCESS_KEY` and `S3_SECRET_KEY` - Your S3 credentials
- `TAXPRO_ASPID` and `TAXPRO_PASSWORD` - Your TaxPro credentials

### 4. Run the Setup Script
```bash
./setup.sh
```

This will:
- Build all Docker images
- Start all containers
- Run database migrations
- Seed the database

## 🐳 Manual Setup (Alternative)

If you prefer to run commands manually:

### 1. Build Images
```bash
# Build frontend images
docker build -t ankpal-frontend:dev-local ../quasar-frontend -f ../quasar-frontend/Dockerfile --build-arg VITE_API_BASE=http://localhost:3000/api
docker build -t ankpal-frontend:uat-local ../quasar-frontend -f ../quasar-frontend/Dockerfile --build-arg VITE_API_BASE=http://localhost:3001/api

# Build backend images
docker build -t ankpal-backend:dev-local ../nest-backend -f ../nest-backend/Dockerfile
docker build -t ankpal-backend:uat-local ../nest-backend -f ../nest-backend/Dockerfile
```

### 2. Start Containers
```bash
docker-compose up -d
```

### 3. Run Migrations and Seeding
```bash
# Run migrations
docker-compose exec backend-dev npm run migrate:ankpal

# Seed database
docker-compose exec backend-dev curl -X GET http://localhost:3000/seeder/seed
```

## 🌐 Access Points

After setup, you can access:

- **Development Frontend**: http://localhost:8080
- **Development Backend API**: http://localhost:3000
- **UAT Frontend**: http://localhost:8081  
- **UAT Backend API**: http://localhost:3001
- **Nginx (Main)**: http://localhost:80

## 📊 Monitoring

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend-dev
docker-compose logs -f frontend-dev
```

### Check Container Status
```bash
docker-compose ps
```

### Check Database
```bash
docker-compose exec postgres psql -U ankpal_user -d ankpal_db
```

## 🛠️ Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using the port
   netstat -tulpn | grep :3000
   
   # Kill the process or change ports in docker-compose.yml
   ```

2. **Database Connection Issues**
   ```bash
   # Check if postgres container is running
   docker-compose ps postgres
   
   # Check postgres logs
   docker-compose logs postgres
   ```

3. **Frontend Build Issues**
   ```bash
   # Rebuild frontend images
   docker-compose build frontend-dev frontend-uat
   docker-compose up -d frontend-dev frontend-uat
   ```

4. **Backend Migration Issues**
   ```bash
   # Run migrations manually
   docker-compose exec backend-dev node dist/migrations/migration-runner.js ankpal
   ```

### Reset Everything
```bash
# Stop and remove all containers
docker-compose down

# Remove all images
docker-compose down --rmi all

# Remove volumes (WARNING: This will delete all data)
docker-compose down -v

# Start fresh
./setup.sh
```

## 🔧 Development

### Making Changes

1. **Frontend Changes**: The frontend containers will auto-reload
2. **Backend Changes**: Restart the backend container:
   ```bash
   docker-compose restart backend-dev
   ```

### Adding New Environment Variables

1. Add to `.env` file
2. Add to `env/backend.dev.env` and `env/backend.uat.env`
3. Restart containers:
   ```bash
   docker-compose restart
   ```

## 📁 File Structure

```
infra/
├── .env                          # Main environment variables
├── env.example                   # Environment template
├── env/
│   ├── backend.dev.env          # Development backend config
│   └── backend.uat.env          # UAT backend config
├── nginx/
│   └── logs/                    # Nginx log files
├── docker-compose.yml           # Main compose file
├── docker-compose.override.yml  # Local overrides
├── nginx.conf                   # Nginx configuration
├── setup.sh                     # Setup script
└── DOCKER_SETUP_GUIDE.md        # This guide
```

## 🚨 Security Notes

- Change all default passwords
- Use strong JWT secrets
- Don't commit `.env` files to version control
- Use proper AWS credentials with minimal permissions
- Regularly update Docker images

## 📞 Support

If you encounter issues:

1. Check the logs: `docker-compose logs -f`
2. Verify all environment variables are set
3. Ensure all required services are running
4. Check network connectivity between containers
5. Verify database migrations completed successfully
