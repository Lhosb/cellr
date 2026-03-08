class CreateRegions < ActiveRecord::Migration[8.1]
  def change
    create_table :regions do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end

    add_index :regions, :normalized_name, unique: true
  end
end
