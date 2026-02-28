# frozen_string_literal: true

module Mutations
  class SignOut < BaseMutation
    description "Sign out the current user by clearing the auth cookie"

    field :success, Boolean, null: false

    def resolve
      context[:clear_cookie].call
      { success: true }
    end
  end
end
