module Mutations
  class CancelAppointment < BaseMutation
    description "Cancels an appointment if it belongs to the current patient and is more than 1 hour away."

    argument :id, ID, required: true

    field :appointment, Types::AppointmentType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      user = context[:current_user]

      if user.nil? || user.patient.nil?
        return { appointment: nil, errors: ["You must be logged in as a patient to cancel an appointment."] }
      end

      appointment = user.patient.appointments.find_by(id: id)

      if appointment.nil?
        return { appointment: nil, errors: ["Appointment not found or you don't have permission."] }
      end

      if appointment.cancellable?
        if appointment.update(status: :cancelled)
          { appointment: appointment, errors: [] }
        else
          { appointment: nil, errors: appointment.errors.full_messages }
        end
      else
        { appointment: appointment, errors: ["This appointment is not cancellable. It must be more than 1 hour in the future and not already completed/cancelled."] }
      end
    end
  end
end
