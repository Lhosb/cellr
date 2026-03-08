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
    end
  end
end