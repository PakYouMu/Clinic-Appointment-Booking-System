# frozen_string_literal: true

module Types
  class RecentActivityType < Types::BaseObject
    field :id, ID, null: false
    field :type, String, null: false # e.g., 'appointment_created', 'status_updated', 'doctor_added'
    field :title, String, null: false
    field :description, String, null: false
    field :timestamp, GraphQL::Types::ISO8601DateTime, null: false
    field :icon_type, String, null: false # For frontend icon selection: 'star', 'stethoscope', 'calendar', etc.
    field :color, String, null: false # 'blue', 'green', 'orange', 'red'
  end
end
