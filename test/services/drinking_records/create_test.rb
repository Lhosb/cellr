require "test_helper"

module DrinkingRecords
  class CreateTest < ActiveSupport::TestCase
    test "creates record and updates session activity" do
      user = build_user
      cellar = user.default_cellar_or_fallback
      wine = cellar.wines.create!(winery: winery_named("Mugneret"), wine_name: "Echezeaux", vintage: 2021)
      consumed_at = Time.zone.parse("2026-03-07 21:15:00")

      assert_difference("DrinkingRecord.count", 1) do
        record = Create.call(
          user:,
          cellar_entry: wine,
          consumed_at:,
          tasting_notes: "Silky and floral",
          quantity: 2
        )

        assert_equal CellarEntry.find_by!(cellar_id: cellar.id, wine_id: wine.id).id, record.cellar_entry_id
        assert_equal "Silky and floral", record.tasting_notes
        assert_equal 2, record.quantity
        assert_equal consumed_at.to_i, record.consumed_at.to_i
      end

      session = user.active_drinking_session(date: consumed_at.to_date)
      assert_equal consumed_at.to_i, session.last_activity_at.to_i
    end
  end
end
