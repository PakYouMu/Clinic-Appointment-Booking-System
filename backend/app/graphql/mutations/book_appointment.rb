module Mutations
  class BookAppointment < BaseMutation
    # Arguments the frontend must provide
    argument :doctor_id, ID, required: true
    argument :start_datetime, GraphQL::Types::ISO8601DateTime, required: true
    argument :end_datetime, GraphQL::Types::ISO8601DateTime, required: true
    argument :reason_for_visit, String, required: false
    argument :contact_number, String, required: true
    argument :send_email, Boolean, required: false, default_value: false

    # What the frontend gets back
    field :appointment, Types::AppointmentType, null: true
    field :errors, [String], null: false

    def resolve(doctor_id:, start_datetime:, end_datetime:, contact_number:, reason_for_visit: nil, send_email: false)
      user = context[:current_user]

      # 1. Security Check: Must be logged in and must be a patient
      if user.nil? || user.patient.nil?
        return { appointment: nil, errors: ["You must be logged in as a patient to book an appointment."] }
      end

      # 2. Build the appointment using the logged-in user's patient record
      appointment = user.patient.appointments.build(
        doctor_id: doctor_id,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        reason_for_visit: reason_for_visit,
        contact_number: contact_number,
        status: :booked
      )

      # 3. Attempt to save. This automatically triggers our custom validations!
      if appointment.save
        
        # Optionally send the confirmation email asynchronously (so it doesn't slow down the request)
        if send_email && defined?(AppointmentMailer)
          AppointmentMailer.with(appointment: appointment).booking_confirmation.deliver_later
        end

        { appointment: appointment, errors: [] }
      else
        # If the 1-hour rule or double-booking rule fails, the errors will be returned here
        { appointment: nil, errors: appointment.errors.full_messages }
      end
    end
  end
end