class BackfillRegionsFromWines < ActiveRecord::Migration[8.1]
  UNKNOWN_REGION_NAME = "Unknown".freeze
  UNKNOWN_REGION_NORMALIZED = "unknown".freeze

  def up
    execute <<~SQL
      INSERT INTO regions (name, normalized_name, created_at, updated_at)
      SELECT DISTINCT
        TRIM(w.region) AS name,
        LOWER(REGEXP_REPLACE(TRIM(w.region), '\\s+', ' ', 'g')) AS normalized_name,
        NOW(),
        NOW()
      FROM wines w
      WHERE w.region IS NOT NULL
        AND TRIM(w.region) <> ''
      ON CONFLICT (normalized_name) DO NOTHING;
    SQL

    execute <<~SQL
      INSERT INTO regions (name, normalized_name, created_at, updated_at)
      VALUES ('#{UNKNOWN_REGION_NAME}', '#{UNKNOWN_REGION_NORMALIZED}', NOW(), NOW())
      ON CONFLICT (normalized_name) DO NOTHING;
    SQL

    execute <<~SQL
      UPDATE wines w
      SET region_id = r.id
      FROM regions r
      WHERE w.region_id IS NULL
        AND w.region IS NOT NULL
        AND TRIM(w.region) <> ''
        AND r.normalized_name = LOWER(REGEXP_REPLACE(TRIM(w.region), '\\s+', ' ', 'g'));
    SQL

    execute <<~SQL
      UPDATE wines w
      SET region_id = r.id
      FROM regions r
      WHERE w.region_id IS NULL
        AND r.normalized_name = '#{UNKNOWN_REGION_NORMALIZED}';
    SQL
  end

  def down
    execute <<~SQL
      UPDATE wines
      SET region_id = NULL;
    SQL

    execute <<~SQL
      DELETE FROM regions
      WHERE normalized_name = '#{UNKNOWN_REGION_NORMALIZED}';
    SQL
  end
end
