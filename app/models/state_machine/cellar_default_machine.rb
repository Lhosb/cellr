module StateMachine
  class CellarDefaultMachine < Machine
    def initialize
      super(initial: :not_default)

      event :make_default do
        transition from: [ :not_default, :default ], to: :default
      end

      event :clear_default do
        transition from: [ :default, :not_default ], to: :not_default
      end
    end
  end
end
