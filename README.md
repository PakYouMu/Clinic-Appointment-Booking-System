# Mustard Clinic Appointment Booking System

Mustard Clinic is a functional MVP Web Application designed to streamline the clinic appointment process. This high-performance monorepo provides a seamless experience for both patients and staff, featuring a robust Rails 8 backend and specialized Vue 3 frontends for client booking and administrative management.

## Architecture

This monorepo is structured for scalability and clear separation of concerns:

- **[`backend/`](./backend)**: Rails 8 API with [GraphQL-Ruby](https://graphql-ruby.org/) and secure JWT authentication via `HttpOnly` cookies.
- **[`client/`](./client)**: Vue 3 + Apollo Client + Tailwind CSS v4 + Shadcn Vue. The patient-facing booking portal.
- **[`admin/`](./admin)**: Vue 3 + Apollo Client + Tailwind CSS v4 + Shadcn Vue. The internal staff management dashboard.

## 🛠 Tech Stack

### Backend
- **Ruby 3.4.8** & **Rails 8.1**
- **GraphQL**: Type-safe API with self-documenting schema.
- **Authentication**: JWT-based, secured with `HttpOnly`, `SameSite=Strict` cookies.
- **Background Jobs**: Solid Queue (Rails 8 default).
- **Database**: PostgreSQL.

### Frontend (Client & Admin)
- **Vue 3**: Composition API with `<script setup>`.
- **Styling**: Tailwind CSS v4 + Shadcn Vue (Reka UI).
- **Data Fetching**: Apollo Client (Vue Apollo Composable).
- **Build Tool**: Vite for near-instant HMR.

## Local Setup

### 1. Prerequisites
- **Ruby 3.4.8**
- **Node.js** (Latest LTS recommended)
- **PostgreSQL** (Ensure the service is running)

### 2. Automatic Installation
Install all dependencies (npm packages and Ruby gems) for all projects with one command:
```bash
npm run install:all
```

### 3. Database Initialization
Prepare the PostgreSQL database and seed initial clinic data (Doctors & Schedules):
```bash
cd backend
bin/rails db:prepare
```

### 4. Development
Start all services (Backend, Worker, Client, Admin) concurrently:
```bash
npm run dev
```

The system will be available at:
- **Patient Portal**: [http://localhost:5173](http://localhost:5173)
- **Admin Dashboard**: [http://localhost:5174](http://localhost:5174)
- **GraphQL API**: [http://localhost:3000/graphql](http://localhost:3000/graphql)

---

## Individual Commands

If you need to run specific parts of the system:

| Service | Command | Port |
| :--- | :--- | :--- |
| **All-in-One** | `npm run dev` | All |
| **Backend** | `npm run dev:backend` | 3000 |
| **Worker** | `npm run dev:worker` | - |
| **Client** | `npm run dev:client` | 5173 |
| **Admin** | `npm run dev:admin` | 5174 |

*Note: You can also use `./launch.sh` for a shell-script based startup.*

## Repository Structure

```text
.
├── admin/          # Admin management frontend
├── backend/        # Rails 8 GraphQL API
├── client/         # Patient booking frontend
├── tasks/          # PRDs and project tracking
└── AGENTS.md       # Design system and brand guidelines
```
