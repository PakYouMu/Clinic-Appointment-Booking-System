module Mutations
  class CreateSchedule < BaseMutation
    argument :doctor_id, ID, required: true
    argument :date, GraphQL::Types::ISO8601Date, required: true
    argument :start_time, String, required: true # Frontend sends "09:00"
    argument :end_time, String, required: true   # Frontend sends "17:00"

    field :schedule, Types::ScheduleType, null: true
    field :errors, [String], null: false

    def resolve(doctor_id:, date:, start_time:, end_time:)
      unless context[:current_user]&.admin?
        return { schedule: nil, errors: ["Unauthorized. Admin access required."] }
      end

      doctor = Doctor.find_by(id: doctor_id)
      return { schedule: nil, errors: ["Doctor not found"] } unless doctor

      schedule = doctor.schedules.new(date: date, start_time: start_time, end_time: end_time)

      if schedule.save
        { schedule: schedule, errors: [] }
      else
        { schedule: nil, errors: schedule.errors.full_messages }
      end
    end
  end
end