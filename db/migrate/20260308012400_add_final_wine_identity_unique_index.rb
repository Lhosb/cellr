class AddFinalWineIdentityUniqueIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = "index_wines_on_global_identity".freeze

  def up
    add_index :wines,
              "winery_id, LOWER(name), COALESCE(LOWER(varietal), ''), COALESCE(LOWER(wine_type), '')",
              unique: true,
              name: INDEX_NAME,
              algorithm: :concurrently
  end

  def down
    remove_index :wines, name: INDEX_NAME, algorithm: :concurrently, if_exists: true
  end
end
