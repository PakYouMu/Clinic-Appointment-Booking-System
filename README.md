# Vue 3 + Rails 8 + GraphQL Boilerplate (Monorepo)

A secure, performance-oriented monorepo boilerplate featuring a Rails 8 GraphQL API and two separate Vue 3 frontends (Client and Admin).

## Architecture

This is a monorepo containing:

- **[`backend/`](./backend)**: Rails 8 API with [GraphQL-Ruby](https://graphql-ruby.org/) and JWT authentication via HttpOnly cookies.
- **[`client/`](./client)**: Vue 3 + Apollo Client + Tailwind CSS v4 + Shadcn Vue (Consumer Frontend).
- **[`admin/`](./admin)**: Vue 3 + Apollo Client + Tailwind CSS v4 + Shadcn Vue (Admin Dashboard).

## 🛠 Tech Stack

### Backend
- **Ruby 3.4.8** on **Rails 8.1**
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

## Quick Start

### 1. Prerequisites
- Ruby 3.4.8
- Node.js (Latest LTS)
- PostgreSQL

### 2. Setup (Automatic)
Install dependencies for all three projects at once from the root directory:
```bash
npm run install:all
```

### 3. Launching the Project

#### **All-in-one (Recommended)**
Start the backend and both frontends simultaneously with a single command:
```bash
npm run dev
```
*Alternatively, use the shell script:* `./launch.sh`

#### **Individual Projects**
If you want to work on only one part of the monorepo, you can use these shortcuts from the root:
- **Client only**: `npm run dev:client` (Port 5173)
- **Admin only**: `npm run dev:admin` (Port 5174)
- **Backend only**: `npm run dev:backend` (Port 3000)

> [!NOTE]
> Even though the backend is a **Ruby on Rails** application, the root `package.json` includes the `dev:backend` script as a convenient wrapper for `cd backend && bin/rails s`. You can still run it the "traditional" way if you prefer.

---

## Hosting Strategy

### **Frontend (Vercel)**
- Deploy `client` and `admin` as two separate Vercel projects pointing to this same repository.
- Set the **Root Directory** settings in Vercel to `client` and `admin` respectively.
- Use subdomains (e.g., `app.example.com` and `admin.example.com`).

### **Backend (Render / Railway)**
- Deploy the `backend` folder as a Web Service.
- Connect a managed PostgreSQL database.
- Ensure your production URLs are added to `config/initializers/cors.rb`.

### **Render (Hobby Tier)**
Render allows up to 2 custom domains on the hobby tier.
1. Use one for your API (`api.example.com`).
2. Use Vercel for the frontends to save Render's domain slots and take advantage of Vercel's superior edge network.

## Authentication Flow

The boilerplate uses a secure cookie-based JWT flow:
1. **Sign Up/In**: Mutation sets an `_vue_boilerplate_token` HttpOnly cookie.
2. **Persistence**: The browser automatically sends the cookie with every GraphQL request (via `credentials: 'include'`).
3. **Guard**: Vue Router checks the `currentUser` query before entering protected routes.
4. **Sign Out**: Mutation clears the cookie server-side.
