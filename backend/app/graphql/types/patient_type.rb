# frozen_string_literal: true

module Types
  class PatientType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :phone_number, String, null: true
    
    # Associations
    field :user, Types::UserType, null: false
    
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end