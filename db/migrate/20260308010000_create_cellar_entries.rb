class CreateCellarEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :cellar_entries do |t|
      t.references :cellar, null: false, foreign_key: true
      t.references :wine, null: false, foreign_key: true
      t.integer :vintage
      t.integer :purchase_price_cents, null: false, default: 0
      t.integer :state, null: false, default: 0
      t.datetime :drunk_at
      t.integer :bottle_size_ml
      t.text :notes
      t.text :tasting_notes

      t.timestamps
    end

    add_index :cellar_entries, [ :cellar_id, :state ]
  end
end
