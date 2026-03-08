require "test_helper"

class WineMachineTest < ActiveSupport::TestCase
  test "drink transition resolves from in_cellar to drunk" do
    machine = StateMachine::WineMachine.new

    assert_equal :drunk, machine.transition_for(event: :drink, from: :in_cellar)
  end

  test "restore transition resolves from drunk to in_cellar" do
    machine = StateMachine::WineMachine.new

    assert_equal :in_cellar, machine.transition_for(event: :restore, from: :drunk)
  end

  test "before transition callback adds consumed_at" do
    machine = StateMachine::WineMachine.new
    wine = build_cellar.wines.create!(winery: winery_named("Tempier"), wine_name: "Bandol", vintage: 2022)

    transition = StateMachine::Transition.new(
      record: wine,
      event: :drink,
      from: :in_cellar,
      to: :drunk,
      context: {}
    )

    machine.run_before_callbacks(transition)

    assert transition.context[:consumed_at].present?
  end
end
