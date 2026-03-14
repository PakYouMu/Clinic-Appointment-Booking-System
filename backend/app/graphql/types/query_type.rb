# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Global Object ID for Apollo to reach via graphql
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :current_user, Types::UserType, null: true, description: "Returns the currently authenticated user"
    def current_user
      context[:current_user]
    end
    
    # Doctor Queries
    field :doctors, [Types::DoctorType], null: false, description: "Returns a list of all active doctors"
    def doctors
      Doctor.where(is_active: true).order(:last_name)
    end

    field :doctor, Types::DoctorType, null: true do
      description "Find a specific doctor by ID"
      argument :id, ID, required: true
    end
    def doctor(id:)
      Doctor.find_by(id: id, is_active: true)
    end

    # Patient Queries
    field :my_appointments, [Types::AppointmentType], null: false do
      description "Returns UPCOMING appointments for the logged-in patient"
    end
    
    def my_appointments
      user = context[:current_user]
      
      # Loud Error for unauthorized access
      unless user&.patient?
        raise GraphQL::ExecutionError, "You must be logged in as a patient to view your appointments."
      end

      # Filter for future appointments only
      user.patient.appointments
          .where("start_datetime >= ?", Time.current)
          .order(start_datetime: :asc)
    end

    # Admin Queries
    field :admin_appointments, [Types::AppointmentType], null: false do
      description "Returns appointments for admins with optional filters for Daily/Weekly views"
      argument :date, GraphQL::Types::ISO8601Date, required: false      # For Daily View
      argument :from_date, GraphQL::Types::ISO8601Date, required: false # For Weekly View start
      argument :to_date, GraphQL::Types::ISO8601Date, required: false   # For Weekly View end
      argument :doctor_id, ID, required: false                          # Filter by specific doctor
    end

    def admin_appointments(date: nil, from_date: nil, to_date: nil, doctor_id: nil)
      user = context[:current_user]
      
      # Loud Error for unauthorized access
      unless user&.admin?
        raise GraphQL::ExecutionError, "You are not authorized to view the admin dashboard."
      end

      # Start with all appointments (eager load to prevent N+1 issues)
      appointments = Appointment.includes(:patient, :doctor).order(start_datetime: :asc)

      # Apply Filters
      appointments = appointments.where(doctor_id: doctor_id) if doctor_id

      if date
        appointments = appointments.where("DATE(start_datetime) = ?", date)
      end

      if from_date && to_date
        appointments = appointments.where("DATE(start_datetime) >= ? AND DATE(start_datetime) <= ?", from_date, to_date)
      elsif from_date
        appointments = appointments.where("DATE(start_datetime) >= ?", from_date)
      end

      appointments
    end
  end
end