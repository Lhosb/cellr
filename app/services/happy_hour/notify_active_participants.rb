module HappyHour
  class NotifyActiveParticipants
    def self.call(actor:, record:)
      ::DrinkLoggedNotifier.with(actor:, wine: record.cellar_entry).deliver_later
    end
  end
end
