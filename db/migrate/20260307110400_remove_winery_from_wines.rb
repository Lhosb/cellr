class RemoveWineryFromWines < ActiveRecord::Migration[8.1]
  class MigrationWine < ApplicationRecord
    self.table_name = "wines"
  end

  class MigrationWinery < ApplicationRecord
    self.table_name = "wineries"
  end

  def up
    remove_column :wines, :winery, :string
  end

  def down
    add_column :wines, :winery, :string, null: false, default: ""

    MigrationWine.reset_column_information
    MigrationWinery.reset_column_information

    MigrationWine.find_each do |wine|
      winery_name = MigrationWinery.find_by(id: wine.winery_id)&.name.to_s
      wine.update_columns(winery: winery_name, updated_at: Time.current)
    end

    change_column_default :wines, :winery, nil
  end
end
