require "test_helper"

module DrinkingSessions
  class StartTest < ActiveSupport::TestCase
    test "creates a session for the current date" do
      user = build_user
      time = Time.zone.parse("2026-03-07 18:00:00")

      assert_difference("DrinkingSession.count", 1) do
        session = Start.call(user:, time:)

        assert_equal user.id, session.user_id
        assert_equal Date.new(2026, 3, 7), session.date
        assert_equal time.to_i, session.started_at.to_i
        assert_equal time.to_i, session.last_activity_at.to_i
        assert_nil session.ended_at
      end
    end

    test "reuses same-day session and updates activity" do
      user = build_user
      first_time = Time.zone.parse("2026-03-07 17:00:00")
      second_time = Time.zone.parse("2026-03-07 19:00:00")

      session = Start.call(user:, time: first_time)
      session.update!(ended_at: first_time + 10.minutes)

      assert_no_difference("DrinkingSession.count") do
        started_again = Start.call(user:, time: second_time)
        assert_equal session.id, started_again.id
        assert_nil started_again.reload.ended_at
        assert_equal second_time.to_i, started_again.last_activity_at.to_i
      end
    end
  end
end
