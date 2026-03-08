module Cellars
  class SetDefault
    def self.call(user:, cellar:, machine: StateMachine::CellarDefaultMachine.new)
      membership = user.cellar_memberships.find_by!(cellar:)

      ActiveRecord::Base.transaction do
        user.cellar_memberships.default_for_user.where.not(id: membership.id).find_each do |other_membership|
          transition_to_not_default!(membership: other_membership, machine:)
        end

        transition_to_default!(membership:, machine:)
      end

      membership
    end

    def self.transition_to_default!(membership:, machine:)
      to_state = machine.transition_for(event: :make_default, from: membership.default_state)
      membership.update!(default: to_state == :default)
    end
    private_class_method :transition_to_default!

    def self.transition_to_not_default!(membership:, machine:)
      to_state = machine.transition_for(event: :clear_default, from: membership.default_state)
      membership.update!(default: to_state == :default)
    end
    private_class_method :transition_to_not_default!
  end
end
