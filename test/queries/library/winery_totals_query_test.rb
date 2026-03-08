require "test_helper"

module Library
  class WineryTotalsQueryTest < ActiveSupport::TestCase
    test "aggregates bottles consumed by winery across wines" do
      user = build_user
      main_winery = winery_named("Main House")
      second_winery = winery_named("Elsewhere")

      main_wine_one = Wine.create!(winery: main_winery, name: "One")
      main_wine_two = Wine.create!(winery: main_winery, name: "Two")
      second_wine = Wine.create!(winery: second_winery, name: "Three")

      main_entry_one = CellarEntry.create!(cellar: build_cellar(owner: user), wine: main_wine_one, vintage: 2020)
      main_entry_two = CellarEntry.create!(cellar: build_cellar(owner: user), wine: main_wine_two, vintage: 2021)
      second_entry = CellarEntry.create!(cellar: build_cellar(owner: user), wine: second_wine, vintage: 2022)

      session = build_session(user)

      DrinkingRecord.create!(drinking_session: session, cellar_entry: main_entry_one, quantity: 2, consumed_at: Time.current)
      DrinkingRecord.create!(drinking_session: session, cellar_entry: main_entry_two, quantity: 3, consumed_at: Time.current)
      DrinkingRecord.create!(drinking_session: session, cellar_entry: second_entry, quantity: 1, consumed_at: Time.current)

      row = WineryTotalsQuery.new.call.find { |result| result.winery_id == main_winery.id }

      assert_not_nil row
      assert_equal 5, row.bottles_drank.to_i
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
