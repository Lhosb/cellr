module Library
  class WineryTotalsQuery
    def initialize(scope: DrinkingRecord.all, user_id: nil)
      @scope = scope
      @user_id = user_id
    end

    def call(limit: 100)
      relation = @scope.joins(:drinking_session, cellar_entry: { wine: :winery })
      relation = relation.where(drinking_sessions: { user_id: @user_id }) if @user_id.present?

      relation
        .select(
          "wineries.id AS winery_id",
          "wineries.name AS winery_name",
          "COALESCE(SUM(drinking_records.quantity), 0) AS bottles_drank"
        )
        .group("wineries.id, wineries.name")
        .order(Arel.sql("COALESCE(SUM(drinking_records.quantity), 0) DESC, wineries.name ASC"))
        .limit(limit)
    end
  end
end
