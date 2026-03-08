class DropLegacyWineColumnsAndIndexes < ActiveRecord::Migration[8.1]
  def up
    remove_index :wines, name: "index_wines_on_cellar_id_and_canonical_key", if_exists: true
    remove_index :wines, name: "index_wines_on_cellar_id", if_exists: true
    remove_index :wines, name: "index_wines_on_normalized_wine_name", if_exists: true
    remove_index :wines, name: "index_wines_on_normalized_winery", if_exists: true

    remove_foreign_key :wines, :cellars if foreign_key_exists?(:wines, :cellars)

    remove_column :wines, :cellar_id, :bigint, if_exists: true
    remove_column :wines, :canonical_key, :string, if_exists: true
    remove_column :wines, :normalized_wine_name, :string, if_exists: true
    remove_column :wines, :normalized_winery, :string, if_exists: true
    remove_column :wines, :purchase_price_cents, :integer, if_exists: true
    remove_column :wines, :region, :string, if_exists: true
    remove_column :wines, :vintage, :integer, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Legacy wine column cleanup cannot be safely reversed"
  end
end
