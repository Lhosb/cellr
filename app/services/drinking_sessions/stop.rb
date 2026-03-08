module DrinkingSessions
  class Stop
    def self.call(user:, time: Time.current)
      session = user.active_drinking_session(date: time.to_date)
      return nil unless session

      session.update!(ended_at: time, last_activity_at: time)

      ActiveRecord.after_all_transactions_commit do
        HappyHour::BroadcastUpdate.call
      end

      session
    end
  end
end
