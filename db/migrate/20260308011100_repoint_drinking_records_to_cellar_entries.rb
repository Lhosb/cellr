class RepointDrinkingRecordsToCellarEntries < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE drinking_records dr
      SET cellar_entry_id = ce.id
      FROM cellar_entries ce
      JOIN wines w ON w.id = ce.wine_id
      WHERE dr.cellar_entry_id = w.id
        AND ce.cellar_id = w.cellar_id;
    SQL

    remove_foreign_key :drinking_records, column: :cellar_entry_id
    add_foreign_key :drinking_records, :cellar_entries, column: :cellar_entry_id
  end

  def down
    execute <<~SQL
      UPDATE drinking_records dr
      SET cellar_entry_id = ce.wine_id
      FROM cellar_entries ce
      WHERE dr.cellar_entry_id = ce.id;
    SQL

    remove_foreign_key :drinking_records, column: :cellar_entry_id
    add_foreign_key :drinking_records, :wines, column: :cellar_entry_id
  end
end
