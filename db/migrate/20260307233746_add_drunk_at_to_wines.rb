class AddDrunkAtToWines < ActiveRecord::Migration[8.1]
  def change
    add_column :wines, :drunk_at, :datetime
  end
end
