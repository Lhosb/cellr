require "test_helper"

module Library
  class WineTotalsQueryTest < ActiveSupport::TestCase
    test "aggregates bottles across vintages for the same wine" do
      target_user = build_user
      other_user = build_user
      winery = winery_named("Field Recordings")

      wine = Wine.create!(winery:, name: "Troublemaker")
      another_wine = Wine.create!(winery:, name: "Skins")

      first_entry = CellarEntry.create!(cellar: build_cellar(owner: target_user), wine:, vintage: 2020)
      second_entry = CellarEntry.create!(cellar: build_cellar(owner: other_user), wine:, vintage: 2021)
      other_entry = CellarEntry.create!(cellar: build_cellar(owner: target_user), wine: another_wine, vintage: 2022)

      target_session = build_session(target_user)
      other_session = build_session(other_user)

      DrinkingRecord.create!(drinking_session: target_session, cellar_entry: first_entry, quantity: 2, consumed_at: Time.current)
      DrinkingRecord.create!(drinking_session: other_session, cellar_entry: second_entry, quantity: 3, consumed_at: Time.current)
      DrinkingRecord.create!(drinking_session: target_session, cellar_entry: other_entry, quantity: 1, consumed_at: Time.current)

      row = WineTotalsQuery.new.call.find { |result| result.wine_id == wine.id }

      assert_not_nil row
      assert_equal 5, row.bottles_drank.to_i
    end

    test "supports user scoped totals" do
      target_user = build_user
      other_user = build_user
      winery = winery_named("Rails Winery")
      wine = Wine.create!(winery:, name: "Scoped Bottle")

      target_entry = CellarEntry.create!(cellar: build_cellar(owner: target_user), wine:, vintage: 2020)
      other_entry = CellarEntry.create!(cellar: build_cellar(owner: other_user), wine:, vintage: 2021)

      DrinkingRecord.create!(drinking_session: build_session(target_user), cellar_entry: target_entry, quantity: 4, consumed_at: Time.current)
      DrinkingRecord.create!(drinking_session: build_session(other_user), cellar_entry: other_entry, quantity: 2, consumed_at: Time.current)

      row = WineTotalsQuery.new(user_id: target_user.id).call.find { |result| result.wine_id == wine.id }

      assert_not_nil row
      assert_equal 4, row.bottles_drank.to_i
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
