Ankpal Monoinfra - Dev and UAT on one EC2

Overview
This folder contains a production-ready docker-compose, Nginx reverse proxy, and environment files to run:
- dev: dev.xyz.com and dev.xyz.com/api
- uat: uat.xyz.com and uat.xyz.com/api
Both point to the same shared PostgreSQL database as requested.

Structure
- docker-compose.yml: Base stack pulling images from registry
- docker-compose.override.yml: Local-only override to build from local repos
- nginx.conf, nginx/conf.d/{dev,uat}.conf: Virtual hosts and proxying
- env/backend.*.env: NestJS env files mounted into containers

Prerequisites
- Docker and Docker Compose v2
- Domains pointing to EC2 public IP: dev.xyz.com, uat.xyz.com
- Security group allows ports 80/443 (HTTPS not configured here; consider using a load balancer or certbot container)

Quick start (local)
1) Copy .env.example to .env and set values (images or keep for local builds):
   - FRONTEND_DEV_IMAGE, BACKEND_DEV_IMAGE, FRONTEND_UAT_IMAGE, BACKEND_UAT_IMAGE
   - POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB
2) Start with local builds:
   docker compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
3) Add host entries to test locally:
   127.0.0.1 dev.xyz.com
   127.0.0.1 uat.xyz.com
4) Open http://localhost (dev) and http://localhost:81 (uat)

EC2 Deployment
1) Create ECR repos: ankpal-frontend, ankpal-backend
2) Build and push images per branch:
   - Frontend develop -> ankpal-frontend:dev-<SHA>
   - Backend develop  -> ankpal-backend:dev-<SHA>
   - Frontend master  -> ankpal-frontend:uat-<SHA>
   - Backend master   -> ankpal-backend:uat-<SHA>
   Also push floating tags latest-dev and latest-uat for convenience if desired.
3) On EC2:
   - Clone infra folder (or this repo) to /opt/ankpal/infra
   - Create .env from .env.example and set image tags to the pushed ones
   - docker compose pull && docker compose up -d

Environment and secrets
- Backend env files are mounted from ./env/*.env and can reference top-level .env vars (e.g., ${POSTGRES_USER}).
- You can switch to AWS Secrets Manager by injecting env at runtime via docker compose "env_file" or SSM template rendering.

Notes
- Both dev and uat backend containers point to the same Postgres as requested. For isolation later, define another service or RDS instance.
- SSL: For production, put an ALB/ELB in front with ACM certs, or run an nginx-proxy + certbot-companion.

.env keys
Set these in infra/.env:
```
FRONTEND_DEV_IMAGE=123456789012.dkr.ecr.ap-south-1.amazonaws.com/ankpal-frontend:dev-SHA
BACKEND_DEV_IMAGE=123456789012.dkr.ecr.ap-south-1.amazonaws.com/ankpal-backend:dev-SHA
FRONTEND_UAT_IMAGE=123456789012.dkr.ecr.ap-south-1.amazonaws.com/ankpal-frontend:uat-SHA
BACKEND_UAT_IMAGE=123456789012.dkr.ecr.ap-south-1.amazonaws.com/ankpal-backend:uat-SHA

POSTGRES_USER=ankpal
POSTGRES_PASSWORD=changeme
POSTGRES_DB=ankpal
```

Frontend image note
- The Nginx proxy expects the frontend containers to listen on port 8080. If your Dockerfile serves on port 80 (common with nginx), either change the compose `expose` and Nginx `proxy_pass` to 80, or modify the frontend image to listen on 8080.


