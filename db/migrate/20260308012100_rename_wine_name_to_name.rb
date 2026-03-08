class RenameWineNameToName < ActiveRecord::Migration[8.1]
  def change
    rename_column :wines, :wine_name, :name
  end
end
