module Mutations
  class CreateDoctor < BaseMutation
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :specialty, String, required: true

    field :doctor, Types::DoctorType, null: true
    field :errors, [String], null: false

    def resolve(first_name:, last_name:, specialty:)
      # Security check: Ensure the user is logged in AND is an admin
      unless context[:current_user]&.admin?
        return { doctor: nil, errors: ["Unauthorized. Admin access required."] }
      end

      doctor = Doctor.new(first_name: first_name, last_name: last_name, specialty: specialty)
      
      if doctor.save
        { doctor: doctor, errors: [] }
      else
        { doctor: nil, errors: doctor.errors.full_messages }
      end
    end
  end
end