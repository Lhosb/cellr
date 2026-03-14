module Library
  class TopCellaredWinesQuery
    def initialize(user: nil)
      @user = user
    end

    def call(limit: 5)
      if @user.present?
        cellar_ids = @user.cellars.select(:id)
        scope = Wine.joins(:cellar_entries).where(cellar_entries: { cellar_id: cellar_ids, state: :in_cellar })
      else
        scope = Wine.joins(:cellar_entries).where(cellar_entries: { state: :in_cellar })
      end

      scope
        .joins(:winery)
        .select("wines.*, wineries.name AS winery_name, COUNT(cellar_entries.id) AS bottles")
        .group("wines.id, wineries.name")
        .order(Arel.sql("COUNT(cellar_entries.id) DESC, wines.name ASC"))
        .limit(limit)
    end
  end
end
