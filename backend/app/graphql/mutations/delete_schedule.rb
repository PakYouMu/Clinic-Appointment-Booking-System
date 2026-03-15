module Mutations
  class DeleteSchedule < BaseMutation
    description "Deletes a single schedule (shift) by its ID"

    argument :schedule_id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(schedule_id:)
      unless context[:current_user]&.admin?
        return { success: false, errors: ["Unauthorized. Admin access required."] }
      end

      schedule = Schedule.find_by(id: schedule_id)
      return { success: false, errors: ["Schedule not found"] } unless schedule

      if schedule.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: schedule.errors.full_messages }
      end
    end
  end
end
