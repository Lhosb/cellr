class RebuildWineSearchIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    remove_index :wines, name: "index_wines_on_wine_name", algorithm: :concurrently, if_exists: true
    add_index :wines, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_wines_on_name", algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :wines, name: "index_wines_on_name", algorithm: :concurrently, if_exists: true
    add_index :wines, :wine_name, using: :gin, opclass: :gin_trgm_ops, name: "index_wines_on_wine_name", algorithm: :concurrently
  end
end
