module DrinkingRecords
  class Create
    def self.call(user:, cellar_entry:, consumed_at: Time.current, tasting_notes: nil, quantity: 1)
      record = ActiveRecord::Base.transaction do
        session = DrinkingSessions::Start.call(user:, time: consumed_at)

        record = session.drinking_records.create!(
          cellar_entry:,
          consumed_at:,
          tasting_notes:,
          quantity:
        )

        session.update!(last_activity_at: consumed_at)
        record
      end

      ActiveRecord.after_all_transactions_commit do
        HappyHour::BroadcastUpdate.call
        HappyHour::NotifyActiveParticipants.call(actor: user, record:)
      end

      record
    end
  end
end
