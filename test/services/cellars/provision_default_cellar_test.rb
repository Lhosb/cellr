require "test_helper"

module Cellars
  class ProvisionDefaultCellarTest < ActiveSupport::TestCase
    test "creates cellar and owner membership when missing" do
      user = build_user

      user.cellar_memberships.destroy_all
      user.owned_cellars.destroy_all

      assert_difference("Cellar.count", 1) do
        assert_difference("CellarMembership.count", 1) do
          cellar = ProvisionDefaultCellar.call(user:)

          assert_equal user.id, cellar.owner_id
          assert_equal "My Cellar", cellar.name

          membership = CellarMembership.find_by!(cellar:, user:)
          assert_equal "owner", membership.role
        end
      end
    end

    test "uses user name for default cellar name" do
      user = User.create!(email: "named-user@example.com", name: "Luke")

      cellar = ProvisionDefaultCellar.call(user:)

      assert_equal "Luke's Cellar", cellar.name
    end

    test "returns existing owner cellar without creating duplicates" do
      user = build_user
      existing_cellar = user.cellar_memberships.includes(:cellar).find_by!(role: :owner).cellar

      assert_no_difference("Cellar.count") do
        assert_no_difference("CellarMembership.count") do
          result = ProvisionDefaultCellar.call(user:)
          assert_equal existing_cellar.id, result.id
        end
      end
    end
  end
end