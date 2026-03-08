module DrinkingSessions
  class Start
    def self.call(user:, time: Time.current)
      date = time.to_date

      session = DrinkingSession.create_or_find_by!(user:, date:) do |drinking_session|
        drinking_session.started_at = time
        drinking_session.last_activity_at = time
      end

      session.update!(ended_at: nil, last_activity_at: time)

      ActiveRecord.after_all_transactions_commit do
        HappyHour::BroadcastUpdate.call
      end

      session
    end
  end
end
