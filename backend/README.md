# Rails 8 GraphQL API

The backend for the Vue + Rails boilerplate.

## 🛠 Features
- **Rails 8.1** (API-only mode).
- **GraphQL-Ruby** implementation.
- **JWT Authentication**: Secured with HttpOnly, Secure, SameSite=Strict cookies.
- **CORS**: Configured for multiple frontend origins (localhost:5173, localhost:5174).

## 🚀 Getting Started

### Prerequisites
- Ruby 3.4.8
- PostgreSQL

### Installation
1. Install dependencies:
   ```bash
   bundle install
   ```
2. Initialize the database:
   ```bash
   bin/rails db:prepare
   ```
3. Start the server:
   ```bash
   bin/rails server -p 3000
   ```

## 📂 Key Files
- `app/graphql/`: Schema, Types, and Mutations (SignUp, SignIn, SignOut).
- `app/services/auth_token.rb`: JWT encoding/decoding logic.
- `app/controllers/graphql_controller.rb`: Handles cookie-based auth and GQL execution.
- `config/initializers/cors.rb`: Whitelist for frontend origins.
