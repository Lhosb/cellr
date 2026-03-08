class CreateDrinkingRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :drinking_records do |t|
      t.references :drinking_session, null: false, foreign_key: true
      t.references :cellar_entry, null: false, foreign_key: { to_table: :wines }
      t.datetime :consumed_at, null: false
      t.text :tasting_notes
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :drinking_records, [ :drinking_session_id, :consumed_at ], name: "index_drinking_records_on_session_and_consumed_at"
    add_check_constraint :drinking_records, "quantity > 0", name: "check_drinking_records_quantity_positive"
  end
end
