module Library
  class OverviewQuery
    def initialize(user: nil)
      @user = user
    end

    def call
      if @user.present?
        cellar_ids = @user.cellars.select(:id)
        total_bottles = CellarEntry.where(cellar_id: cellar_ids, state: :in_cellar).count
        total_wines = Wine.joins(:cellar_entries).where(cellar_entries: { cellar_id: cellar_ids }).distinct.count("wines.id")
        total_wineries = Winery.joins(wines: :cellar_entries).where(cellar_entries: { cellar_id: cellar_ids }).distinct.count("wineries.id")
      else
        total_bottles = CellarEntry.where(state: :in_cellar).count
        total_wines = Wine.joins(:cellar_entries).distinct.count("wines.id")
        total_wineries = Winery.joins(wines: :cellar_entries).distinct.count("wineries.id")
      end
      drunk_tonight = HappyHour::ActiveSessionsQuery.new.call.count

      {
        total_bottles: total_bottles,
        total_wines: total_wines,
        total_wineries: total_wineries,
        drunk_tonight: drunk_tonight
      }
    end
  end
end
