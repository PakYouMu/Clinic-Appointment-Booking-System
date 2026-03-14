# frozen_string_literal: true

module Types
  class AppointmentType < Types::BaseObject
    field :id, ID, null: false
    field :reason_for_visit, String, null: true
    field :status, String, null: false # Rails Enums return as strings automatically
    
    # The new datetime columns we created in the migration
    field :start_datetime, GraphQL::Types::ISO8601DateTime, null: false
    field :end_datetime, GraphQL::Types::ISO8601DateTime, null: false
    
    # Associations
    field :patient, Types::PatientType, null: false
    field :doctor, Types::DoctorType, null: false
    
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end