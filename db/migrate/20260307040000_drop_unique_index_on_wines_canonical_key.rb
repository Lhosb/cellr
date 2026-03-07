class DropUniqueIndexOnWinesCanonicalKey < ActiveRecord::Migration[8.1]
  def change
    remove_index :wines, name: "index_wines_on_cellar_id_and_canonical_key"
    add_index :wines, [ :cellar_id, :canonical_key ], name: "index_wines_on_cellar_id_and_canonical_key"
  end
end
