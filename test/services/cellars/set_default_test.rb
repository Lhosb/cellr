require "test_helper"

module Cellars
  class SetDefaultTest < ActiveSupport::TestCase
    test "sets selected cellar membership as default" do
      user = build_user
      cellar = Cellar.create!(name: "Second", owner: user)
      membership = CellarMembership.create!(cellar:, user:, role: :owner, default: false)

      SetDefault.call(user:, cellar:)

      assert membership.reload.default
    end

    test "clears prior default when a new cellar is selected" do
      user = build_user
      first = user.default_cellar_or_fallback
      second = Cellar.create!(name: "Two", owner: user)

      first_membership = user.cellar_memberships.find_by!(cellar: first)
      second_membership = CellarMembership.create!(cellar: second, user:, role: :owner, default: false)

      SetDefault.call(user:, cellar: second)

      refute first_membership.reload.default
      assert second_membership.reload.default
    end
  end
end
