class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.date :appointment_date
      t.time :start_time
      t.time :end_time
      t.integer :status
      t.text :reason_for_visit
      t.string :contact_details

      t.timestamps
    end
  end
end
