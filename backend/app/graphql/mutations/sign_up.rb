# frozen_string_literal: true

module Mutations
  class SignUp < BaseMutation
    description "Register a new user and set an auth cookie"

    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(email:, password:, password_confirmation:)
      user = User.new(
        email: email,
        password: password,
        password_confirmation: password_confirmation
      )

      if user.save
        token = AuthToken.encode(user)
        set_auth_cookie(token)
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    end

    private

    def set_auth_cookie(token)
      context[:set_cookie].call(token)
    end
  end
end
