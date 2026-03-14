module Library
  class ByTypeQuery
    def initialize(user:)
      @user = user
    end

    def call
      cellar_ids = @user.cellars.select(:id)

      Wine.joins(:cellar_entries)
          .where(cellar_entries: { cellar_id: cellar_ids, state: :in_cellar })
          .group(Arel.sql("COALESCE(wines.wine_type, 'unknown')"))
          .order(Arel.sql("COUNT(cellar_entries.id) DESC"))
          .count("cellar_entries.id")
          .map { |type, count| { wine_type: type || "unknown", bottles: count } }
    end
  end
end
