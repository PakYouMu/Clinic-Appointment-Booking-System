# frozen_string_literal: true

module Types
  class DoctorType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :specialty, String, null: false
    field :is_active, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    # Embed the schedules for easy frontend booking
    field :schedules, [Types::ScheduleType], null: true

    # Custom resolver to only return today's or future schedules
    def schedules
      object.schedules.where("date >= ?", Date.today).order(date: :asc, start_time: :asc)
    end
  end
end