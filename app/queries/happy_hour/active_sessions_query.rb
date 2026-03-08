module HappyHour
  class ActiveSessionsQuery
    def initialize(scope: DrinkingSession.all)
      @scope = scope
    end

    def call(date: Date.current)
      @scope
        .for_date(date)
        .active
        .includes(:user, drinking_records: { cellar_entry: { wine: :winery } })
        .order(last_activity_at: :desc, id: :desc)
    end
  end
end
