# Vue 3 Admin Frontend

The administrative dashboard for the Vue + Rails boilerplate.

## 🛠 Tech Stack
- **Vue 3** (Composition API).
- **Apollo Client**: GraphQL data layer.
- **Tailwind CSS v4**: Styling.
- **Shadcn Vue**: UI Components.
- **Vue Router**: Auth-guarded routing.

## 🚀 Getting Started

### Installation
1. Install dependencies:
   ```bash
   npm install
   ```
2. Start the dev server:
   ```bash
   npm run dev
   ```
   *Runs on http://localhost:5174 by default.*

## 📂 Project Structure
- `src/views/Home.vue`: Distinct "ADMIN" branded home page.
- `src/composables/useAuth.js`: Shared auth logic (mirrored from client).
- `src/components/ui/`: Shadcn Vue components.

## ⚓ Port Configuration
This app is configured to run on **port 5174** in `vite.config.js` to avoid conflict with the primary client frontend.
