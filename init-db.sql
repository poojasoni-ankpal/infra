-- Database initialization script
-- This script runs automatically when PostgreSQL container starts

-- Create the database user
CREATE USER ankpal_user WITH PASSWORD 'ankpal_password_123';

-- Create the database
CREATE DATABASE ankpal_db OWNER ankpal_user;

-- Grant all privileges to the user
GRANT ALL PRIVILEGES ON DATABASE ankpal_db TO ankpal_user;

-- Connect to the database and set up schema
\c ankpal_db;

-- Create the ankpal schema
CREATE SCHEMA IF NOT EXISTS ankpal;
GRANT ALL ON SCHEMA ankpal TO ankpal_user;

-- Create the tenant1 schema
CREATE SCHEMA IF NOT EXISTS tenant1;
GRANT ALL ON SCHEMA tenant1 TO ankpal_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA ankpal GRANT ALL ON TABLES TO ankpal_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA ankpal GRANT ALL ON SEQUENCES TO ankpal_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA tenant1 GRANT ALL ON TABLES TO ankpal_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA tenant1 GRANT ALL ON SEQUENCES TO ankpal_user;
