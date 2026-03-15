module Resolvers
  class AvailableSlots < GraphQL::Schema::Resolver
    type [String], null: false
    description "Returns an array of available 15-minute start times for a specific doctor on a given date"

    argument :doctor_id, ID, required: true
    argument :date, GraphQL::Types::ISO8601Date, required: true

    def resolve(doctor_id:, date:)
      schedules = Schedule.where(doctor_id: doctor_id, date: date)
      return [] if schedules.empty?

      # Fetch non-cancelled appointments for this doctor.
      # We'll filter by date in Ruby to avoid timezone issues with DATE() in SQL.
      appointments = Appointment.where(doctor_id: doctor_id)
                                .where.not(status: :cancelled)
                                .to_a

      available_slots = []
      now = Time.current

      schedules.each do |schedule|
        # Schedule start_time/end_time are stored as bare time values in the DB.
        # They represent local clinic hours (e.g., 09:00 means 9 AM at the clinic).
        # Extract the raw hours/minutes using .utc to get the stored values
        # without timezone conversion artifacts.
        start_hour = schedule.start_time.hour
        start_min  = schedule.start_time.min
        end_hour   = schedule.end_time.hour
        end_min    = schedule.end_time.min

        # Build proper timezone-aware datetimes for comparison on the specific date.
        # These represent the actual clinic operating hours in the local timezone.
        start_dt = Time.zone.local(date.year, date.month, date.day, start_hour, start_min)
        end_dt   = Time.zone.local(date.year, date.month, date.day, end_hour, end_min)

        current_slot_start = start_dt

        while current_slot_start + 15.minutes <= end_dt
          slot_end = current_slot_start + 15.minutes

          # Rule 1: Must be at least 1 hour in advance
          if current_slot_start > now + 1.hour
            # Rule 2: Cannot overlap with existing booked appointments
            overlap = appointments.any? do |appt|
              # Check if this appointment is on the same date (in local timezone)
              appt_local = appt.start_datetime.in_time_zone(Time.zone)
              next false unless appt_local.to_date == date

              # Check time overlap
              current_slot_start < appt.end_datetime && slot_end > appt.start_datetime
            end

            available_slots << current_slot_start.strftime("%H:%M") unless overlap
          end

          current_slot_start += 15.minutes
        end
      end

      available_slots.uniq.sort
    end
  end
end
