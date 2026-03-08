require "test_helper"

module Library
  class WineVintageBreakdownQueryTest < ActiveSupport::TestCase
    test "returns grouped totals by vintage for selected wine" do
      user = build_user
      winery = winery_named("Breakdown Winery")
      target_wine = Wine.create!(winery:, name: "Target")
      other_wine = Wine.create!(winery:, name: "Other")

      vintage_entry = CellarEntry.create!(cellar: build_cellar(owner: user), wine: target_wine, vintage: 2020)
      unknown_entry = CellarEntry.create!(cellar: build_cellar(owner: user), wine: target_wine, vintage: nil)
      other_entry = CellarEntry.create!(cellar: build_cellar(owner: user), wine: other_wine, vintage: 2021)

      session = build_session(user)

      DrinkingRecord.create!(drinking_session: session, cellar_entry: vintage_entry, quantity: 2, consumed_at: Time.current)
      DrinkingRecord.create!(drinking_session: session, cellar_entry: unknown_entry, quantity: 1, consumed_at: Time.current)
      DrinkingRecord.create!(drinking_session: session, cellar_entry: other_entry, quantity: 7, consumed_at: Time.current)

      rows = WineVintageBreakdownQuery.new.call(wine_id: target_wine.id)
      totals = rows.each_with_object({}) { |row, memo| memo[row.vintage] = row.bottles_drank.to_i }

      assert_equal 2, totals[2020]
      assert_equal 1, totals[nil]
      assert_nil totals[2021]
    end

    private

    def build_session(user)
      DrinkingSession.create!(
        user:,
        date: Date.current,
        started_at: Time.current,
        last_activity_at: Time.current
      )
    end
  end
end
