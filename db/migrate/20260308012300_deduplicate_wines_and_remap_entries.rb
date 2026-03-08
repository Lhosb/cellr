class DeduplicateWinesAndRemapEntries < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      WITH ranked AS (
        SELECT
          id,
          FIRST_VALUE(id) OVER (
            PARTITION BY
              winery_id,
              LOWER(name),
              COALESCE(LOWER(varietal), ''),
              COALESCE(LOWER(wine_type), '')
            ORDER BY id
          ) AS canonical_id,
          ROW_NUMBER() OVER (
            PARTITION BY
              winery_id,
              LOWER(name),
              COALESCE(LOWER(varietal), ''),
              COALESCE(LOWER(wine_type), '')
            ORDER BY id
          ) AS row_number
        FROM wines
      ),
      mapping AS (
        SELECT id AS duplicate_id, canonical_id
        FROM ranked
        WHERE row_number > 1
      )
      UPDATE cellar_entries ce
      SET wine_id = mapping.canonical_id
      FROM mapping
      WHERE ce.wine_id = mapping.duplicate_id;
    SQL

    execute <<~SQL
      WITH ranked AS (
        SELECT
          id,
          FIRST_VALUE(id) OVER (
            PARTITION BY
              winery_id,
              LOWER(name),
              COALESCE(LOWER(varietal), ''),
              COALESCE(LOWER(wine_type), '')
            ORDER BY id
          ) AS canonical_id,
          ROW_NUMBER() OVER (
            PARTITION BY
              winery_id,
              LOWER(name),
              COALESCE(LOWER(varietal), ''),
              COALESCE(LOWER(wine_type), '')
            ORDER BY id
          ) AS row_number
        FROM wines
      ),
      mapping AS (
        SELECT id AS duplicate_id, canonical_id
        FROM ranked
        WHERE row_number > 1
      )
      DELETE FROM wine_tags wt
      USING mapping
      WHERE wt.wine_id = mapping.duplicate_id
        AND EXISTS (
          SELECT 1
          FROM wine_tags canonical_tags
          WHERE canonical_tags.wine_id = mapping.canonical_id
            AND canonical_tags.tag_id = wt.tag_id
        );
    SQL

    execute <<~SQL
      WITH ranked AS (
        SELECT
          id,
          FIRST_VALUE(id) OVER (
            PARTITION BY
              winery_id,
              LOWER(name),
              COALESCE(LOWER(varietal), ''),
              COALESCE(LOWER(wine_type), '')
            ORDER BY id
          ) AS canonical_id,
          ROW_NUMBER() OVER (
            PARTITION BY
              winery_id,
              LOWER(name),
              COALESCE(LOWER(varietal), ''),
              COALESCE(LOWER(wine_type), '')
            ORDER BY id
          ) AS row_number
        FROM wines
      ),
      mapping AS (
        SELECT id AS duplicate_id, canonical_id
        FROM ranked
        WHERE row_number > 1
      )
      UPDATE wine_tags wt
      SET wine_id = mapping.canonical_id
      FROM mapping
      WHERE wt.wine_id = mapping.duplicate_id;
    SQL

    execute <<~SQL
      WITH ranked AS (
        SELECT
          id,
          ROW_NUMBER() OVER (
            PARTITION BY
              winery_id,
              LOWER(name),
              COALESCE(LOWER(varietal), ''),
              COALESCE(LOWER(wine_type), '')
            ORDER BY id
          ) AS row_number
        FROM wines
      )
      DELETE FROM wines
      WHERE id IN (
        SELECT id
        FROM ranked
        WHERE row_number > 1
      );
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Wine deduplication and remap cannot be safely reversed"
  end
end
