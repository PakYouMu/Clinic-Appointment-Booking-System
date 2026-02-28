# Vue 3 Client Frontend

The consumer-facing frontend for the Vue + Rails boilerplate.

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
   *Runs on http://localhost:5173 by default.*

## 📂 Project Structure
- `src/composables/useAuth.js`: Global auth state and methods.
- `src/models/apolloClient.js`: Apollo configuration with cookie support.
- `src/router/index.js`: Protected vs Guest routes.
- `src/views/`: Home (Protected), Login, Register.
- `src/components/ui/`: Shadcn Vue components.
