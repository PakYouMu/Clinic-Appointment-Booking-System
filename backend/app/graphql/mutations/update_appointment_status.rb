module Mutations
  class UpdateAppointmentStatus < BaseMutation
    argument :appointment_id, ID, required: true
    argument :status, String, required: true # e.g., "completed", "no_show", "cancelled"

    field :appointment, Types::AppointmentType, null: true
    field :errors, [String], null: false

    def resolve(appointment_id:, status:)
      user = context[:current_user]
      
      # Security: Only admins can arbitarily change status to completed/no-show
      unless user&.admin?
        return { appointment: nil, errors: ["Unauthorized. Admin access required."] }
      end

      appointment = Appointment.find_by(id: appointment_id)
      return { appointment: nil, errors: ["Appointment not found"] } unless appointment

      # Verify the status is valid based on our Rails Enum
      unless Appointment.statuses.keys.include?(status)
        return { appointment: nil, errors: ["Invalid status. Must be booked, completed, cancelled, or no_show"] }
      end

      if appointment.update(status: status)
        { appointment: appointment, errors: [] }
      else
        { appointment: nil, errors: appointment.errors.full_messages }
      end
    end
  end
end