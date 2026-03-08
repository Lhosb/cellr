module StateMachine
  class WineMachine < Machine
    def initialize
      super(initial: :in_cellar)

      event :drink do
        transition from: :in_cellar, to: :drunk
      end

      event :restore do
        transition from: :drunk, to: :in_cellar
      end

      before_transition on: :drink do |_wine, transition|
        transition.context[:consumed_at] ||= Time.current
      end

      after_transition on: :drink, to: :drunk do |wine, transition|
        actor = transition.context[:actor]
        next unless actor

        DrinkingRecords::Create.call(
          user: actor,
          cellar_entry: wine,
          consumed_at: transition.context[:consumed_at]
        )
      end

      after_transition on: :restore, to: :in_cellar do |wine, transition|
        cellar = transition.context[:cellar]
        next unless cellar

        CellarEntry.restore_for_cellar!(wine:, cellar:)
      end
    end
  end
end
