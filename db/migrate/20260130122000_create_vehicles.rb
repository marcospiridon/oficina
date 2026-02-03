class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.string :license_plate, null: false
      t.references :workshop, null: false, foreign_key: true

      t.timestamps
    end

    add_index :vehicles, [:license_plate, :workshop_id], unique: true
  end
end
