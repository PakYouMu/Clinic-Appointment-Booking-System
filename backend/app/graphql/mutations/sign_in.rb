# frozen_string_literal: true

module Mutations
  class SignIn < BaseMutation
    description "Authenticate a user and set an auth cookie"

    argument :email, String, required: true
    argument :password, String, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(email:, password:)
      user = User.find_by(email: email.strip.downcase)
      
      app_type = context[:app_type]

      if user&.authenticate(password)
        if (app_type == 'admin' && user.admin?) || (app_type == 'patient' && user.patient?)
          token = AuthToken.encode(user)
          set_auth_cookie(token)
          { user: user, errors: [] }
        else
          { user: nil, errors: ["Invalid email or password"] } # Return bad credentials even on role mismatch for security
        end
      else
        { user: nil, errors: ["Invalid email or password"] }
      end
    end

    private

    def set_auth_cookie(token)
      context[:set_cookie].call(token)
    end
  end
end
