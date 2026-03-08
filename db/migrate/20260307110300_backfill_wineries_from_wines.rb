class BackfillWineriesFromWines < ActiveRecord::Migration[8.1]
  class MigrationWine < ApplicationRecord
    self.table_name = "wines"
  end

  class MigrationWinery < ApplicationRecord
    self.table_name = "wineries"
  end

  def up
    MigrationWine.reset_column_information
    MigrationWinery.reset_column_information

    say_with_time "Backfilling wineries from wines.winery" do
      MigrationWine.find_each do |wine|
        raw_name = wine.read_attribute(:winery).to_s.strip
        next if raw_name.blank?

        normalized_name = raw_name.downcase.gsub(/\s+/, " ")
        winery = MigrationWinery.find_or_create_by!(normalized_name:) do |record|
          record.name = raw_name
        end

        wine.update_columns(winery_id: winery.id, updated_at: Time.current)
      end
    end

    change_column_null :wines, :winery_id, false
  end

  def down
    change_column_null :wines, :winery_id, true
  end
end
