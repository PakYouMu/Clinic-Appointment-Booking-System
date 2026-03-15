class AddMissingFieldsToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :contact_number, :string
    add_column :appointments, :notes, :text
  end
end
