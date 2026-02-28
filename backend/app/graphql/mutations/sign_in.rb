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

      if user&.authenticate(password)
        token = AuthToken.encode(user)
        set_auth_cookie(token)
        { user: user, errors: [] }
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
