class AddNotesFieldsToWines < ActiveRecord::Migration[8.1]
  def change
    add_column :wines, :notes, :text
    add_column :wines, :tasting_notes, :text
  end
end
