class CreateDoctors < ActiveRecord::Migration[8.1]
  def change
    create_table :doctors do |t|
      t.string :first_name
      t.string :last_name
      t.string :specialty

      t.timestamps
    end
  end
end
