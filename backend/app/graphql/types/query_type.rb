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
    
    field :available_slots, resolver: Resolvers::AvailableSlots
    
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

      # Return all appointments for dashboard history and upcoming views
      user.patient.appointments.order(start_datetime: :desc)
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

    field :recent_activities, [Types::RecentActivityType], null: false do
      description "Returns a list of recent events for the dashboard"
    end

    def recent_activities
      user = context[:current_user]
      unless user&.admin?
        raise GraphQL::ExecutionError, "You are not authorized to view this data."
      end

      activities = []

      # 1. New Appointments (last 10)
      Appointment.includes(:patient, :doctor).order(created_at: :desc).limit(10).each do |a|
        activities << {
          id: "new-#{a.id}",
          type: 'appointment_created',
          title: "New booking confirmed",
          description: "#{a.patient.first_name} #{a.patient.last_name} with Dr. #{a.doctor.last_name}",
          timestamp: a.created_at,
          icon_type: 'calendar',
          color: 'blue'
        }
      end

      # 2. Updated Appointments (last 10, exclude just created)
      Appointment.includes(:patient, :doctor)
                 .where("updated_at > created_at")
                 .order(updated_at: :desc).limit(10).each do |a|
        status_text = a.status.humanize
        color = case a.status
                when 'completed' then 'green'
                when 'cancelled' then 'red'
                when 'no_show' then 'orange'
                else 'blue'
                end
        
        icon = case a.status
               when 'completed' then 'check'
               when 'cancelled' then 'x'
               else 'clock'
               end

        activities << {
          id: "upd-#{a.id}-#{a.updated_at.to_i}",
          type: 'status_updated',
          title: "Appointment marked as #{status_text}",
          description: "Patient: #{a.patient.last_name}, Doctor: #{a.doctor.last_name}",
          timestamp: a.updated_at,
          icon_type: icon,
          color: color
        }
      end

      # 3. New Doctors
      Doctor.order(created_at: :desc).limit(5).each do |d|
        activities << {
          id: "doc-#{d.id}",
          type: 'doctor_added',
          title: "New specialist onboarded",
          description: "Dr. #{d.first_name} #{d.last_name} joined as #{d.specialty}",
          timestamp: d.created_at,
          icon_type: 'stethoscope',
          color: 'green'
        }
      end

      # Sort all by timestamp descending and return top 6
      activities.sort_by { |a| a[:timestamp] }.reverse.take(6)
    end
  end
end