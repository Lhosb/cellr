require "test_helper"

module Cellars
  class MembershipsControllerTest < ActionDispatch::IntegrationTest
    test "index returns cellar memberships with user payload" do
      owner = User.create!(email: "owner-members-index@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar
      viewer = User.create!(email: "viewer-members-index@example.com")
      CellarMembership.create!(cellar:, user: viewer, role: :viewer)

      get cellar_memberships_path(cellar)

      assert_response :ok
      body = JSON.parse(response.body)

      assert_equal 2, body.size
      roles = body.map { |membership| membership.fetch("role") }
      assert_includes roles, "owner"
      assert_includes roles, "viewer"

      user_emails = body.map { |membership| membership.fetch("user").fetch("email") }
      assert_includes user_emails, owner.email
      assert_includes user_emails, viewer.email
    end

    test "destroy removes non-owner membership" do
      owner = User.create!(email: "owner-members-destroy@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar
      viewer = User.create!(email: "viewer-members-destroy@example.com")
      membership = CellarMembership.create!(cellar:, user: viewer, role: :viewer)

      assert_difference("CellarMembership.count", -1) do
        delete cellar_membership_path(cellar, membership)
      end

      assert_response :no_content
    end

    test "update changes non-owner membership role" do
      owner = User.create!(email: "owner-members-update@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar
      viewer = User.create!(email: "viewer-members-update@example.com")
      membership = CellarMembership.create!(cellar:, user: viewer, role: :viewer)

      patch cellar_membership_path(cellar, membership), params: { role: "editor" }

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "editor", body.fetch("role")
      assert_equal "editor", membership.reload.role
    end

    test "update returns unprocessable entity for invalid role" do
      owner = User.create!(email: "owner-members-invalid-role@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar
      viewer = User.create!(email: "viewer-members-invalid-role@example.com")
      membership = CellarMembership.create!(cellar:, user: viewer, role: :viewer)

      patch cellar_membership_path(cellar, membership), params: { role: "not-a-role" }

      assert_response :unprocessable_entity
      assert_match "not a valid role", JSON.parse(response.body).fetch("error")
      assert_equal "viewer", membership.reload.role
    end

    test "destroy returns unprocessable entity for owner membership" do
      owner = User.create!(email: "owner-members-protected@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar
      owner_membership = cellar.cellar_memberships.find_by!(user: owner)

      assert_no_difference("CellarMembership.count") do
        delete cellar_membership_path(cellar, owner_membership)
      end

      assert_response :unprocessable_entity
      assert_match "cannot be removed", JSON.parse(response.body).fetch("error")
    end

    test "update returns unprocessable entity for owner membership" do
      owner = User.create!(email: "owner-members-update-protected@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar
      owner_membership = cellar.cellar_memberships.find_by!(user: owner)

      patch cellar_membership_path(cellar, owner_membership), params: { role: "editor" }

      assert_response :unprocessable_entity
      assert_match "cannot be changed", JSON.parse(response.body).fetch("error")
      assert_equal "owner", owner_membership.reload.role
    end
  end
end
