# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :phone_number, String, null: true
    field :role, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Resolver methods to reach into Patient model
    def first_name
      object.patient&.first_name
    end

    def last_name
      object.patient&.last_name
    end

    def phone_number
      object.patient&.phone_number
    end
  end
end