# Database Migrations

This directory contains database migration files for the Immigration Chatbot application.

## Migration Naming Convention

Migration files should follow the naming convention:
```
YYYYMMDDHHMMSS_<description>.sql
```

For example:
- `20241201120000_create_owner_change_indexes.sql`

## Running Migrations

Migrations can be executed using PostgreSQL tools or migration frameworks such as:
- [golang-migrate](https://github.com/golang-migrate/migrate)
- [goose](https://github.com/pressly/goose)
- Direct execution via `psql`

## Database Connection

The application uses PostgreSQL database configured in `local-temporal-server.yaml`:
- Host: localhost (or postgresql container)
- Port: 5432
- Database: temporal
- User: temporal
- Password: temporal

## Migration Structure

Each migration file should contain:
1. Forward migration (UP) - Changes to apply
2. Backward migration (DOWN) - How to rollback changes

Use comments to separate UP and DOWN sections when using a single file approach.