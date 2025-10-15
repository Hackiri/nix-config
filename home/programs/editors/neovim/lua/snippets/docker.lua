local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local docker_snippets = {
      -- Multi-stage Node.js
      s(
        "dfnode",
        fmt(
          [[
# Build stage
FROM node:{}-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
{}

# Production stage
FROM node:{}-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./
{}

USER nodejs

EXPOSE {}

CMD ["{}"]
]],
          {
            i(1, "20"),
            i(2, "RUN npm run build"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(3, "COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist"),
            i(4, "3000"),
            i(5, "node", "server.js"),
          }
        )
      ),

      -- Python with Poetry
      s(
        "dfpython",
        fmt(
          [[
FROM python:{}-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    {} \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd -m -u 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE {}

CMD ["python", "{}"]
]],
          {
            i(1, "3.11"),
            i(2, "gcc"),
            i(3, "8000"),
            i(4, "main.py"),
          }
        )
      ),

      -- Go multi-stage
      s(
        "dfgo",
        fmt(
          [[
# Build stage
FROM golang:{}-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Production stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/main .

EXPOSE {}

CMD ["./main"]
]],
          {
            i(1, "1.21"),
            i(2, "8080"),
          }
        )
      ),

      -- Rust multi-stage
      s(
        "dfrust",
        fmt(
          [[
# Build stage
FROM rust:{}-alpine AS builder

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && \
    echo "fn main() {{}}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

COPY . .
RUN cargo build --release

# Production stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/target/release/{} .

EXPOSE {}

CMD ["./{}"]
]],
          {
            i(1, "1.75"),
            i(2, "app"),
            i(3, "8080"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
          }
        )
      ),

      -- Nginx static site
      s(
        "dfnginx",
        fmt(
          [[
FROM nginx:{}-alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static files
COPY {} /usr/share/nginx/html

EXPOSE {}

CMD ["nginx", "-g", "daemon off;"]
]],
          {
            i(1, "alpine"),
            i(2, "dist"),
            i(3, "80"),
          }
        )
      ),

      -- Development Dockerfile
      s(
        "dfdev",
        fmt(
          [[
FROM {}:{}

WORKDIR /app

# Install development dependencies
{}

# Copy dependency files
COPY {} .

# Install dependencies
{}

# Copy source code
COPY . .

# Expose ports
EXPOSE {}

# Development command with hot reload
CMD [{}]
]],
          {
            i(1, "node"),
            i(2, "20-alpine"),
            i(3, "RUN apk add --no-cache git"),
            i(4, "package*.json"),
            i(5, "RUN npm install"),
            i(6, "3000"),
            i(7, '"npm", "run", "dev"'),
          }
        )
      ),

      -- Basic Dockerfile template
      s(
        "dfbasic",
        fmt(
          [[
FROM {}:{}

WORKDIR /app

COPY . .

{}

EXPOSE {}

CMD [{}]
]],
          {
            i(1, "ubuntu"),
            i(2, "22.04"),
            i(3, "# Build commands"),
            i(4, "8080"),
            i(5, '"./app"'),
          }
        )
      ),

      -- .dockerignore file
      s(
        "dockerignore",
        fmt(
          [[
# Git
.git
.gitignore
.gitattributes

# CI/CD
.github
.gitlab-ci.yml

# Dependencies
node_modules
vendor
__pycache__
*.pyc

# Environment
.env
.env.*
!.env.example

# Build artifacts
dist
build
target
*.log

# Documentation
README.md
docs
*.md

# IDE
.vscode
.idea
*.swp
*.swo

{}
]],
          {
            i(1, "# Additional ignores"),
          }
        )
      ),
    }

return docker_snippets
