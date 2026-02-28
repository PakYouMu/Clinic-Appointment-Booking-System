# Vue 3 + Rails 8 + GraphQL Boilerplate (Monorepo)

A secure, performance-oriented monorepo boilerplate featuring a Rails 8 GraphQL API and two separate Vue 3 frontends (Client and Admin).

## 🚀 Architecture

This is a monorepo containing:

- **[`backend/`](./backend)**: Rails 8 API with [GraphQL-Ruby](https://graphql-ruby.org/) and JWT authentication via HttpOnly cookies.
- **[`client/`](./client)**: Vue 3 + Apollo Client + Tailwind CSS v4 + Shadcn Vue (Consumer Frontend).
- **[`admin/`](./admin)**: Vue 3 + Apollo Client + Tailwind CSS v4 + Shadcn Vue (Admin Dashboard).

## 🛠 Tech Stack

### Backend
- **Ruby 3.4.8** & **Rails 8.1**
- **GraphQL**: Type-safe API with self-documenting schema.
- **Authentication**: JWT-based, secured with `HttpOnly`, `SameSite=Strict` cookies.
- **Database**: PostgreSQL (default Rails 8 config).

### Frontend (Client & Admin)
- **Vue 3** (Composition API with `<script setup>`).
- **Apollo Client**: Integrated with Vue for GraphQL data fetching and caching.
- **Vite**: Ultra-fast build tool and dev server.
- **Tailwind CSS v4**: Built-in CSS variables and high performance.
- **Shadcn Vue**: High-quality, accessible UI components.
- **Vue Router**: Client-side routing with authentication guards.

## 🏁 Quick Start

### 1. Prerequisites
- Ruby 3.4.8
- Node.js (Latest LTS)
- PostgreSQL

### 2. Setup Backend
```bash
cd backend
bundle install
bin/rails db:prepare
bin/rails server -p 3000
```

### 3. Setup Client (Port 5173)
```bash
cd client
npm install
npm run dev
```

### 4. Setup Admin (Port 5174)
```bash
cd admin
npm install
npm run dev
```

## 🔐 Authentication Flow

The boilerplate uses a secure cookie-based JWT flow:
1. **Sign Up/In**: Mutation sets an `_vue_boilerplate_token` HttpOnly cookie.
2. **Persistence**: The browser automatically sends the cookie with every GraphQL request (via `credentials: 'include'`).
3. **Guard**: Vue Router checks the `currentUser` query before entering protected routes.
4. **Sign Out**: Mutation clears the cookie server-side.
