# frozen_string_literal: true

module Mutations
  class UpdateDoctor < BaseMutation
    description "Update an existing doctor's details"

    argument :id, ID, required: true
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :specialty, String, required: false
    argument :is_active, Boolean, required: false

    field :doctor, Types::DoctorType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attributes)
      unless context[:current_user]&.admin?
        return { doctor: nil, errors: ["Unauthorized. Admin access required."] }
      end

      doctor = Doctor.find_by(id: id)
      return { doctor: nil, errors: ["Doctor not found."] } unless doctor

      # Only update provided attributes (reject nil values)
      update_attrs = attributes.compact

      if doctor.update(update_attrs)
        { doctor: doctor, errors: [] }
      else
        { doctor: nil, errors: doctor.errors.full_messages }
      end
    end
  end
end
