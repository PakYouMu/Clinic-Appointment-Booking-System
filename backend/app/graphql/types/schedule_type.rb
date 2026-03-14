module Types
  class ScheduleType < Types::BaseObject
    field :id, ID, null: false
    field :doctor_id, Integer, null: false
    field :date, GraphQL::Types::ISO8601Date, null: false
    field :start_time, String, null: false
    field :end_time, String, null: false

    def start_time
      object.start_time.strftime("%H:%M")
    end

    def end_time
      object.end_time.strftime("%H:%M")
    end
  end
end