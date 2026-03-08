class AddWineryReferenceAndStateToWines < ActiveRecord::Migration[8.1]
  def change
    add_reference :wines, :winery, foreign_key: true
    add_column :wines, :state, :integer, null: false, default: 0
  end
end
