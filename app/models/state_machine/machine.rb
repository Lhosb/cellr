module StateMachine
  class Machine
    def initialize(initial:)
      @initial = initial.to_sym
      @events = {}
      @before_callbacks = []
      @around_callbacks = []
      @after_callbacks = []
    end

    def event(name, &block)
      event_name = name.to_sym
      @events[event_name] ||= []
      EventBuilder.new(@events[event_name]).instance_eval(&block)
    end

    def before_transition(filter = {}, &block)
      @before_callbacks << [ normalize_filter(filter), block ]
    end

    def around_transition(filter = {}, &block)
      @around_callbacks << [ normalize_filter(filter), block ]
    end

    def after_transition(filter = {}, &block)
      @after_callbacks << [ normalize_filter(filter), block ]
    end

    def transition_for(event:, from:)
      event_name = event.to_sym
      from_state = from.to_sym

      rules = @events.fetch(event_name) do
        raise InvalidTransition, "event #{event_name} is not defined"
      end

      rule = rules.find do |entry|
        Array(entry[:from]).map(&:to_sym).include?(from_state)
      end

      raise InvalidTransition, "cannot transition via #{event_name} from #{from_state}" unless rule

      rule[:to].to_sym
    end

    def run_before_callbacks(transition)
      run_simple_callbacks(@before_callbacks, transition)
    end

    def run_after_callbacks(transition)
      run_simple_callbacks(@after_callbacks, transition)
    end

    def run_around_callbacks(transition, &action)
      callbacks = matching_callbacks(@around_callbacks, transition)
      return action.call if callbacks.empty?

      wrapped = callbacks.reverse.inject(action) do |next_action, callback|
        lambda do
          yielded = false
          callback.call(transition.record, transition, lambda {
            yielded = true
            next_action.call
          })
          throw :halt unless yielded
        end
      end

      result = catch(:halt) do
        wrapped.call
        :ok
      end

      raise CallbackHalted, "around transition callback halted" unless result == :ok
    end

    private

    def run_simple_callbacks(callbacks, transition)
      matching_callbacks(callbacks, transition).each do |callback|
        result = catch(:halt) do
          callback.call(transition.record, transition)
          :ok
        end

        raise CallbackHalted, "transition callback halted" unless result == :ok
      end
    end

    def matching_callbacks(callbacks, transition)
      callbacks.each_with_object([]) do |(filter, callback), selected|
        next if filter[:on].present? && filter[:on] != transition.event
        next if filter[:from].present? && filter[:from] != transition.from
        next if filter[:to].present? && filter[:to] != transition.to

        selected << callback
      end
    end

    def normalize_filter(filter)
      {
        on: filter[:on]&.to_sym,
        from: filter[:from]&.to_sym,
        to: filter[:to]&.to_sym
      }
    end

    class EventBuilder
      def initialize(rules)
        @rules = rules
      end

      def transition(from:, to:)
        @rules << {
          from: Array(from),
          to: to.to_sym
        }
      end
    end
  end
end
