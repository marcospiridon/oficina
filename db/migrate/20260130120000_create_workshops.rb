class CreateWorkshops < ActiveRecord::Migration[7.1]
  def change
    create_table :workshops do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end
    add_index :workshops, :slug, unique: true
  end
end
