module Mutations
  class BulkCreateSchedules < BaseMutation
    description "Creates multiple schedule blocks for a doctor across a date range"

    argument :doctor_id, ID, required: true
    argument :start_date, GraphQL::Types::ISO8601Date, required: true
    argument :end_date, GraphQL::Types::ISO8601Date, required: true
    argument :start_time, String, required: true # e.g., "09:00"
    argument :end_time, String, required: true   # e.g., "17:00"
    argument :days_of_week, [Integer], required: true # [1, 2, 3, 4, 5] for Mon-Fri

    field :schedules, [Types::ScheduleType], null: true
    field :errors, [String], null: false

    def resolve(doctor_id:, start_date:, end_date:, start_time:, end_time:, days_of_week:)
      unless context[:current_user]&.admin?
        return { schedules: nil, errors: ["Unauthorized. Admin access required."] }
      end

      doctor = Doctor.find_by(id: doctor_id)
      return { schedules: nil, errors: ["Doctor not found"] } unless doctor

      created_schedules = []
      errors = []

      (start_date..end_date).each do |date|
        # Ruby's wday: 0 (Sun) to 6 (Sat).
        # We'll assume the frontend matches this or we'll document it.
        next unless days_of_week.include?(date.wday)

        schedule = doctor.schedules.find_or_initialize_by(date: date)
        schedule.start_time = start_time
        schedule.end_time = end_time

        if schedule.save
          created_schedules << schedule
        else
          errors.concat(schedule.errors.full_messages.map { |msg| "#{date}: #{msg}" })
        end
      end

      {
        schedules: created_schedules,
        errors: errors
      }
    end
  end
end
