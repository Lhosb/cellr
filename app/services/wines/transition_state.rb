module Wines
  class TransitionState
    def initialize(wine:, event:, actor:, context: {}, machine: ::StateMachine::WineMachine.new)
      @wine = wine
      @event = event.to_sym
      @actor = actor
      @context = context
      @machine = machine
    end

    def call
      from = @wine.state.to_sym
      to = @machine.transition_for(event: @event, from:)

      transition = ::StateMachine::Transition.new(
        record: @wine,
        event: @event,
        from:,
        to:,
        context: @context.merge(actor: @actor)
      )

      ActiveRecord::Base.transaction do
        @machine.run_before_callbacks(transition)
        @machine.run_around_callbacks(transition) do
          attrs = { state: to }
          attrs[:drunk_at] = Time.current if to == :drunk
          attrs[:drunk_at] = nil if to == :in_cellar
          @wine.update!(attrs)
        end
      end

      @machine.run_after_callbacks(transition)
      @wine
    end
  end
end
