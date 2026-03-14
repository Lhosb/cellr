module Library
  class TopCellaredWineriesQuery
    def initialize(user: nil)
      @user = user
    end

    def call(limit: 5)
      if @user.present?
        cellar_ids = @user.cellars.select(:id)
        scope = Winery.joins(wines: :cellar_entries).where(cellar_entries: { cellar_id: cellar_ids, state: :in_cellar })
      else
        scope = Winery.joins(wines: :cellar_entries).where(cellar_entries: { state: :in_cellar })
      end

      scope
        .select("wineries.id AS winery_id, wineries.name AS winery_name, COUNT(cellar_entries.id) AS bottles")
        .group("wineries.id, wineries.name")
        .order(Arel.sql("COUNT(cellar_entries.id) DESC, wineries.name ASC"))
        .limit(limit)
    end
  end
end
