require "test_helper"

module HappyHour
  class ActiveSessionsQueryTest < ActiveSupport::TestCase
    test "returns only active sessions for the requested date ordered by latest activity" do
      user_one = build_user
      user_two = build_user
      target_date = Date.new(2026, 3, 7)

      older = DrinkingSession.create!(
        user: user_one,
        date: target_date,
        started_at: Time.zone.parse("2026-03-07 17:00:00"),
        last_activity_at: Time.zone.parse("2026-03-07 18:00:00")
      )

      newer = DrinkingSession.create!(
        user: user_two,
        date: target_date,
        started_at: Time.zone.parse("2026-03-07 18:00:00"),
        last_activity_at: Time.zone.parse("2026-03-07 20:00:00")
      )

      DrinkingSession.create!(
        user: build_user,
        date: target_date,
        started_at: Time.zone.parse("2026-03-07 15:00:00"),
        last_activity_at: Time.zone.parse("2026-03-07 16:00:00"),
        ended_at: Time.zone.parse("2026-03-07 16:30:00")
      )

      DrinkingSession.create!(
        user: build_user,
        date: target_date - 1.day,
        started_at: Time.zone.parse("2026-03-06 19:00:00"),
        last_activity_at: Time.zone.parse("2026-03-06 20:00:00")
      )

      results = ActiveSessionsQuery.new.call(date: target_date).to_a

      assert_equal [ newer.id, older.id ], results.map(&:id)
    end
  end
end
