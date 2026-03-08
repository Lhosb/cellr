class AddRegionReferenceToWines < ActiveRecord::Migration[8.1]
  def change
    add_reference :wines, :region, foreign_key: true, null: true
  end
end
