module Library
  class TopCellaredWineriesQuery
    def initialize(user:)
      @user = user
    end

    def call(limit: 5)
      cellar_ids = @user.cellars.select(:id)

      Winery.joins(wines: :cellar_entries)
            .where(cellar_entries: { cellar_id: cellar_ids, state: :in_cellar })
            .select("wineries.id AS winery_id, wineries.name AS winery_name, COUNT(cellar_entries.id) AS bottles")
            .group("wineries.id, wineries.name")
            .order(Arel.sql("COUNT(cellar_entries.id) DESC, wineries.name ASC"))
            .limit(limit)
    end
  end
end
