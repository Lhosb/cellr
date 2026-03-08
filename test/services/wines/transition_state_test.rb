require "test_helper"

module Wines
  class TransitionStateTest < ActiveSupport::TestCase
    test "drink transitions wine state" do
      wine = build_cellar.wines.create!(winery: winery_named("Tempier"), wine_name: "Bandol", vintage: 2022)

      TransitionState.new(wine:, event: :drink, actor: build_user).call

      assert_equal "drunk", wine.reload.state
    end

    test "raises for invalid transition" do
      wine = build_cellar.wines.create!(winery: winery_named("Tempier"), wine_name: "Bandol", vintage: 2022, state: :drunk)

      assert_raises(::StateMachine::InvalidTransition) do
        TransitionState.new(wine:, event: :drink, actor: build_user).call
      end
    end

    test "raises when callback halts transition" do
      wine = build_cellar.wines.create!(winery: winery_named("Tempier"), wine_name: "Bandol", vintage: 2022)
      machine = ::StateMachine::Machine.new(initial: :in_cellar)
      machine.event :drink do
        transition from: :in_cellar, to: :drunk
      end
      machine.before_transition(on: :drink) { throw :halt }

      assert_raises(::StateMachine::CallbackHalted) do
        TransitionState.new(wine:, event: :drink, actor: build_user, machine:).call
      end

      assert_equal "in_cellar", wine.reload.state
    end
  end
end
