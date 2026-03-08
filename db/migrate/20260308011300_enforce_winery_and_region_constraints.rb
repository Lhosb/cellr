class EnforceWineryAndRegionConstraints < ActiveRecord::Migration[8.1]
  def up
    null_winery_count = select_value("SELECT COUNT(*) FROM wines WHERE winery_id IS NULL").to_i
    raise "Cannot enforce winery_id NOT NULL: #{null_winery_count} rows missing winery_id" if null_winery_count.positive?

    null_region_count = select_value("SELECT COUNT(*) FROM wines WHERE region_id IS NULL").to_i
    raise "Cannot enforce region_id NOT NULL: #{null_region_count} rows missing region_id" if null_region_count.positive?

    change_column_null :wines, :winery_id, false
    change_column_null :wines, :region_id, false
  end

  def down
    change_column_null :wines, :region_id, true
  end
end
