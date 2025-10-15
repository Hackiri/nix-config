local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local docker_compose_snippets = {
      -- Basic compose file
      s(
        "dcbase",
        fmt(
          [[
version: '3.8'

services:
  {}:
    image: {}
    container_name: {}
    restart: unless-stopped
    ports:
      - "{}:{}"]],
          {
            i(1, "app"),
            i(2, "image-name"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(3, "8080"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
          }
        )
      ),

      -- Node.js service
      s(
        "dcnode",
        fmt(
          [[
  {}:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: {}
    restart: unless-stopped
    environment:
      - NODE_ENV={}
      - PORT={}
    ports:
      - "{}:${}"
    volumes:
      - .:/usr/src/app
      - /usr/src/app/node_modules
    depends_on:
      - {}]],
          {
            i(1, "node-app"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "development"),
            i(3, "3000"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            i(4, "mongodb"),
          }
        )
      ),

      -- Database service (MongoDB)
      s(
        "dcmongo",
        fmt(
          [[
  mongodb:
    image: mongo:{}
    container_name: mongodb
    restart: unless-stopped
    environment:
      - MONGO_INITDB_ROOT_USERNAME={}
      - MONGO_INITDB_ROOT_PASSWORD={}
      - MONGO_INITDB_DATABASE={}
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db

volumes:
  mongodb_data:]],
          {
            i(1, "latest"),
            i(2, "root"),
            i(3, "password"),
            i(4, "mydatabase"),
          }
        )
      ),

      -- Database service (PostgreSQL)
      s(
        "dcpostgres",
        fmt(
          [[
  postgres:
    image: postgres:{}
    container_name: postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER={}
      - POSTGRES_PASSWORD={}
      - POSTGRES_DB={}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:]],
          {
            i(1, "latest"),
            i(2, "postgres"),
            i(3, "password"),
            i(4, "mydatabase"),
          }
        )
      ),

      -- Redis service
      s(
        "dcredis",
        fmt(
          [[
  redis:
    image: redis:{}
    container_name: redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes{}

volumes:
  redis_data:]],
          {
            i(1, "alpine"),
            i(2, " --requirepass mypassword"),
          }
        )
      ),

      -- Nginx reverse proxy
      s(
        "dcnginx",
        fmt(
          [[
  nginx:
    image: nginx:{}
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - {}]],
          {
            i(1, "alpine"),
            i(2, "app"),
          }
        )
      ),

      -- Development environment
      s(
        "dcdev",
        fmt(
          [[
version: '3.8'

services:
  {}:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: {}
    restart: unless-stopped
    environment:
      - NODE_ENV=development
    ports:
      - "{}:${}"
    volumes:
      - .:/app
      - /app/node_modules
    command: {}]],
          {
            i(1, "dev"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "3000"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            i(3, "npm run dev"),
          }
        )
      ),

      -- Full stack setup
      s(
        "dcfullstack",
        fmt(
          [[
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: frontend
    restart: unless-stopped
    ports:
      - "{}:${}"
    environment:
      - VITE_API_URL=http://backend:{}

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: backend
    restart: unless-stopped
    ports:
      - "{}:${}"
    environment:
      - DATABASE_URL=postgres://{}:{}@postgres:5432/{}
    depends_on:
      - postgres

  postgres:
    image: postgres:alpine
    container_name: postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=${{POSTGRES_USER:-{}}}
      - POSTGRES_PASSWORD=${{POSTGRES_PASSWORD:-{}}}
      - POSTGRES_DB=${{POSTGRES_DB:-{}}}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:]],
          {
            i(1, "3000"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "5000"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            i(3, "postgres"),
            i(4, "password"),
            i(5, "myapp"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            f(function(args)
              return args[1][1]
            end, { 4 }),
            f(function(args)
              return args[1][1]
            end, { 5 }),
          }
        )
      ),
    }

return docker_compose_snippets
