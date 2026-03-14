module Library
  class TopCellaredWinesQuery
    def initialize(user:)
      @user = user
    end

    def call(limit: 5)
      cellar_ids = @user.cellars.select(:id)

        Wine.joins(:cellar_entries)
          .where(cellar_entries: { cellar_id: cellar_ids, state: :in_cellar })
          .joins(:winery)
          .select("wines.*, wineries.name AS winery_name, COUNT(cellar_entries.id) AS bottles")
          .group("wines.id, wineries.name")
          .order(Arel.sql("COUNT(cellar_entries.id) DESC, wines.name ASC"))
          .limit(limit)
    end
  end
end
