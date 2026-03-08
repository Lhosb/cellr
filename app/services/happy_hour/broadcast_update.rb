module HappyHour
  class BroadcastUpdate
    STREAM_NAME = "happy_hour".freeze
    FEED_TARGET = "happy_hour_feed".freeze

    def self.call
      sessions = ActiveSessionsQuery.new.call

      Turbo::StreamsChannel.broadcast_replace_to(
        STREAM_NAME,
        target: FEED_TARGET,
        partial: "happy_hour/feed",
        locals: { active_sessions: sessions }
      )
    end
  end
end
