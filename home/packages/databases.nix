# Database client tools and utilities
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Relational Databases
    #--------------------------------------------------
    postgresql # PostgreSQL client tools (psql, pg_dump, etc.)
    sqlite # SQLite database engine and CLI
    mariadb.client # MySQL/MariaDB client tools

    #--------------------------------------------------
    # NoSQL Databases
    #--------------------------------------------------
    redis # Redis client (redis-cli)
    mongodb-tools # MongoDB client tools (mongosh, mongodump, etc.)

    #--------------------------------------------------
    # Database Management Tools
    #--------------------------------------------------
    # pgcli # PostgreSQL CLI with autocomplete (optional)
    # mycli # MySQL CLI with autocomplete (optional)
  ];
}
