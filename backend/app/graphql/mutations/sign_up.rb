# frozen_string_literal: true

module Mutations
  class SignUp < BaseMutation
    description "Register a new patient user and set an auth cookie"

    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :phone_number, String, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(email:, password:, password_confirmation:, first_name:, last_name:, phone_number:)
      # Sanitize email
      clean_email = email.strip.downcase

      user = User.new(
        email: clean_email,
        password: password,
        password_confirmation: password_confirmation,
        role: :patient
      )
      
      # Use a transaction to ensure both User and Patient succeed or fail together
      ActiveRecord::Base.transaction do
        if user.save
          patient = Patient.new(user: user, first_name: first_name, last_name: last_name, phone_number: phone_number)

          if patient.save
            token = AuthToken.encode(user)
            set_auth_cookie(token)
            
            return { user: user, errors: [] }
          else
            # Rollback the User creation if the Patient fails validation
            raise ActiveRecord::Rollback, patient.errors.full_messages
          end
        else
          return { user: nil, errors: user.errors.full_messages }
        end
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