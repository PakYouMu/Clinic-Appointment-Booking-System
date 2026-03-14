# frozen_string_literal: true

module Mutations
  class AdminSignUp < BaseMutation
    description "Register a new admin user and set an auth cookie"

    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(email:, password:, password_confirmation:)
      # Sanitize email
      clean_email = email.strip.downcase

      user = User.new(
        email: clean_email,
        password: password,
        password_confirmation: password_confirmation,
        role: :admin
      )

      if user.save
        token = AuthToken.encode(user)
        set_auth_cookie(token)
        
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    rescue StandardError => e
      { user: nil, errors: [e.message] }
    end

    private

    def set_auth_cookie(token)
      context[:set_cookie].call(token)
    end
  end
end
