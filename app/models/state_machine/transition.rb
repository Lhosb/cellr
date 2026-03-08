module StateMachine
  class Transition
    attr_reader :record, :event, :from, :to, :context

    def initialize(record:, event:, from:, to:, context: {})
      @record = record
      @event = event.to_sym
      @from = from.to_sym
      @to = to.to_sym
      @context = context
    end
  end
end
