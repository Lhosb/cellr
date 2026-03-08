require "test_helper"

class CellarDefaultMachineTest < ActiveSupport::TestCase
  setup do
    @machine = StateMachine::CellarDefaultMachine.new
  end

  test "make_default transitions from not_default to default" do
    assert_equal :default, @machine.transition_for(event: :make_default, from: :not_default)
  end

  test "make_default transitions from default to default (idempotent)" do
    assert_equal :default, @machine.transition_for(event: :make_default, from: :default)
  end

  test "clear_default transitions from default to not_default" do
    assert_equal :not_default, @machine.transition_for(event: :clear_default, from: :default)
  end

  test "clear_default transitions from not_default to not_default (idempotent)" do
    assert_equal :not_default, @machine.transition_for(event: :clear_default, from: :not_default)
  end
end
