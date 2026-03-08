class BackfillCellarEntriesFromWines < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      INSERT INTO cellar_entries (
        cellar_id,
        wine_id,
        vintage,
        purchase_price_cents,
        state,
        drunk_at,
        bottle_size_ml,
        notes,
        tasting_notes,
        created_at,
        updated_at
      )
      SELECT
        w.cellar_id,
        w.id,
        w.vintage,
        w.purchase_price_cents,
        w.state,
        w.drunk_at,
        w.bottle_size_ml,
        w.notes,
        w.tasting_notes,
        w.created_at,
        w.updated_at
      FROM wines w
      LEFT JOIN cellar_entries ce
        ON ce.wine_id = w.id
       AND ce.cellar_id = w.cellar_id
      WHERE ce.id IS NULL;
    SQL
  end

  def down
    execute <<~SQL
      DELETE FROM cellar_entries ce
      USING wines w
      WHERE ce.wine_id = w.id
        AND ce.cellar_id = w.cellar_id;
    SQL
  end
end
