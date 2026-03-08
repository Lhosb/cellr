module DrinkingRecords
  class Create
    def self.call(user:, cellar_entry:, consumed_at: Time.current, tasting_notes: nil, quantity: 1)
      resolved_cellar_entry = resolve_cellar_entry(cellar_entry)

      record = ActiveRecord::Base.transaction do
        session = DrinkingSessions::Start.call(user:, time: consumed_at)

        record = session.drinking_records.create!(
          cellar_entry: resolved_cellar_entry,
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

    def self.resolve_cellar_entry(cellar_entry)
      return cellar_entry if cellar_entry.is_a?(CellarEntry)

      if cellar_entry.is_a?(Wine)
        return CellarEntry.from_wine!(cellar_entry)
      end

      raise ArgumentError, "Expected CellarEntry or Wine, got #{cellar_entry.class.name}"
    end
    private_class_method :resolve_cellar_entry
  end
end
