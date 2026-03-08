require "test_helper"

module DrinkingSessions
  class StopTest < ActiveSupport::TestCase
    test "stops active session for current date" do
      user = build_user
      start_time = Time.zone.parse("2026-03-07 18:00:00")
      stop_time = Time.zone.parse("2026-03-07 20:00:00")

      session = Start.call(user:, time: start_time)
      stopped_session = Stop.call(user:, time: stop_time)

      assert_equal session.id, stopped_session.id
      assert_equal stop_time.to_i, stopped_session.ended_at.to_i
      assert_equal stop_time.to_i, stopped_session.last_activity_at.to_i
    end

    test "returns nil when no active session exists" do
      user = build_user

      assert_nil Stop.call(user:)
    end
  end
end