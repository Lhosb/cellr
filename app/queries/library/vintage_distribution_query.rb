module Library
  class VintageDistributionQuery
    def initialize(user:)
      @user = user
    end

    def call
      cellar_ids = @user.cellars.select(:id)

      rows = CellarEntry.where(cellar_id: cellar_ids)
                        .where.not(vintage: nil)
                        .group(Arel.sql("(cellar_entries.vintage / 10) * 10"))
                        .order(Arel.sql("(cellar_entries.vintage / 10) * 10 DESC"))
                        .count

      # normalize into array of { decade: 1990, bottles: 12 }
      rows.map { |decade, count| { decade: decade.to_i, bottles: count } }
    end
  end
end
