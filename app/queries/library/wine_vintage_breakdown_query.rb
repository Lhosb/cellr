module Library
  class WineVintageBreakdownQuery
    def initialize(scope: DrinkingRecord.all, user_id: nil)
      @scope = scope
      @user_id = user_id
    end

    def call(wine_id:)
      relation = @scope.joins(:drinking_session, cellar_entry: :wine).where(cellar_entries: { wine_id: wine_id })
      relation = relation.where(drinking_sessions: { user_id: @user_id }) if @user_id.present?

      relation
        .select(
          "cellar_entries.vintage AS vintage",
          "COALESCE(SUM(drinking_records.quantity), 0) AS bottles_drank"
        )
        .group("cellar_entries.vintage")
        .order(Arel.sql("COALESCE(SUM(drinking_records.quantity), 0) DESC, cellar_entries.vintage DESC NULLS LAST"))
    end
  end
end
