class UpdateClinicSchema < ActiveRecord::Migration[8.1]
  def change
    # 1. Add is_active to Doctors
    add_column :doctors, :is_active, :boolean, default: true, null: false

    # 2. Fix Appointment status default
    change_column_default :appointments, :status, from: nil, to: 0

    # 3. Combine Date and Time into Datetime for easier logic
    add_column :appointments, :start_datetime, :datetime
    add_column :appointments, :end_datetime, :datetime
    
    # Remove the old split columns
    remove_column :appointments, :appointment_date, :date
    remove_column :appointments, :start_time, :time
    remove_column :appointments, :end_time, :time
  end
end