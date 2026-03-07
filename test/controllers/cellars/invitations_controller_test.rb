require "test_helper"

module Cellars
  class InvitationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as
    end

    test "index returns pending invitations for cellar" do
      owner = User.create!(email: "owner-index@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar

      pending = CellarInvitation.create!(
        cellar:,
        invited_by: owner,
        email: "pending@example.com",
        role: :viewer,
        token: "pending-token"
      )
      CellarInvitation.create!(
        cellar:,
        invited_by: owner,
        email: "accepted@example.com",
        role: :viewer,
        token: "accepted-token",
        accepted_at: Time.current
      )

      get cellar_invitations_path(cellar), as: :json

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal 1, body.size
      assert_equal pending.id, body.first.fetch("id")
      assert_equal "pending@example.com", body.first.fetch("email")
    end

    test "create invitation returns created payload" do
      owner = User.create!(email: "owner-invites@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar

      assert_difference("CellarInvitation.count", 1) do
        post cellar_invitations_path(cellar), params: {
          invited_by_id: owner.id,
          email: "friend@example.com",
          role: "editor"
        }, as: :json
      end

      assert_response :created
      body = JSON.parse(response.body)
      assert_equal cellar.id, body["cellar_id"]
      assert_equal "friend@example.com", body["email"]
      assert_equal "editor", body["role"]
      assert body["token"].present?
    end

    test "create invitation returns unprocessable entity for invalid role" do
      owner = User.create!(email: "owner-invalid-role@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar

      assert_no_difference("CellarInvitation.count") do
        post cellar_invitations_path(cellar), params: {
          invited_by_id: owner.id,
          email: "friend@example.com",
          role: "not-a-role"
        }, as: :json
      end

      assert_response :unprocessable_entity
      assert_match "not a valid role", JSON.parse(response.body)["error"]
    end

    test "accept invitation creates membership" do
      inviter = User.create!(email: "inviter-accept@example.com")
      invited = User.create!(email: "invitee-accept@example.com")
      cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: inviter,
        email: invited.email,
        role: :editor,
        token: "accept-token-1"
      )

      assert_difference("CellarMembership.count", 1) do
        post accept_cellar_invitation_path(invitation.token), params: { user_id: invited.id }, as: :json
      end

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal cellar.id, body["cellar_id"]
      assert_equal invited.id, body["user_id"]
      assert_equal "editor", body["role"]
      assert invitation.reload.accepted_at.present?
    end

    test "show invitation page renders for invited user" do
      inviter = User.create!(email: "inviter-show@example.com")
      invited = User.create!(email: "invitee-show@example.com")
      cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: inviter,
        email: invited.email,
        role: :viewer,
        token: "show-token"
      )

      sign_in invited
      get cellar_invitation_token_path(invitation.token)

      assert_response :ok
      assert_match "Cellar Invitation", response.body
      assert_match cellar.name, response.body
    end

    test "accept invitation via html uses current user" do
      inviter = User.create!(email: "inviter-accept-html@example.com")
      invited = User.create!(email: "invitee-accept-html@example.com")
      cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: inviter,
        email: invited.email,
        role: :editor,
        token: "accept-html-token"
      )

      sign_in invited

      assert_difference("CellarMembership.count", 1) do
        post accept_cellar_invitation_path(invitation.token)
      end

      assert_redirected_to cellar_path(cellar)
      assert_equal "editor", CellarMembership.find_by!(cellar:, user: invited).role
    end

    test "accept invitation returns unprocessable entity for mismatched email" do
      inviter = User.create!(email: "inviter-mismatch@example.com")
      invited = User.create!(email: "invitee-mismatch@example.com")
      wrong_user = User.create!(email: "wrong-user@example.com")
      cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: inviter,
        email: invited.email,
        role: :viewer,
        token: "accept-token-2"
      )

      assert_no_difference("CellarMembership.count") do
        post accept_cellar_invitation_path(invitation.token), params: { user_id: wrong_user.id }, as: :json
      end

      assert_response :unprocessable_entity
      assert_match "does not match", JSON.parse(response.body)["error"]
    end

    test "destroy invitation removes record" do
      owner = User.create!(email: "owner-destroy@example.com")
      cellar = owner.cellar_memberships.find_by!(role: :owner).cellar
      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: owner,
        email: "remove-me@example.com",
        role: :viewer,
        token: "destroy-token"
      )

      assert_difference("CellarInvitation.count", -1) do
        delete cellar_invitation_path(cellar, invitation), as: :json
      end

      assert_response :no_content
    end
  end
end
