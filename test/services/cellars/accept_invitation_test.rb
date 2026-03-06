require "test_helper"

module Cellars
  class AcceptInvitationTest < ActiveSupport::TestCase
    test "accepts pending invitation and creates membership" do
      inviter = build_user(email_suffix: "inviter")
      invited_user = build_user(email_suffix: "invited")
      cellar = Cellar.create!(name: "Team Cellar", owner: inviter)

      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: inviter,
        email: invited_user.email,
        role: :editor,
        token: "abc123"
      )

      membership = AcceptInvitation.call(token: invitation.token, user: invited_user)

      assert_equal cellar.id, membership.cellar_id
      assert_equal invited_user.id, membership.user_id
      assert_equal "editor", membership.role
      assert invitation.reload.accepted_at.present?
    end

    test "raises error when invitation email does not match user" do
      inviter = build_user(email_suffix: "inviter2")
      invited_user = build_user(email_suffix: "invited2")
      wrong_user = build_user(email_suffix: "wrong")
      cellar = Cellar.create!(name: "Mismatch Cellar", owner: inviter)

      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: inviter,
        email: invited_user.email,
        role: :viewer,
        token: "mismatch-token"
      )

      error = assert_raises(AcceptInvitation::InvitationError) do
        AcceptInvitation.call(token: invitation.token, user: wrong_user)
      end

      assert_match "does not match", error.message
      assert_nil invitation.reload.accepted_at
      assert_nil CellarMembership.find_by(cellar:, user: wrong_user)
    end

    test "raises error when invitation is missing or already accepted" do
      user = build_user(email_suffix: "missing")

      error = assert_raises(AcceptInvitation::InvitationError) do
        AcceptInvitation.call(token: "does-not-exist", user:)
      end

      assert_match "not found", error.message
    end

    test "updates existing membership role when accepting invitation" do
      inviter = build_user(email_suffix: "inviter3")
      invited_user = build_user(email_suffix: "invited3")
      cellar = Cellar.create!(name: "Existing Membership", owner: inviter)

      existing = CellarMembership.create!(cellar:, user: invited_user, role: :viewer)
      invitation = CellarInvitation.create!(
        cellar:,
        invited_by: inviter,
        email: invited_user.email,
        role: :editor,
        token: "role-update"
      )

      membership = AcceptInvitation.call(token: invitation.token, user: invited_user)

      assert_equal existing.id, membership.id
      assert_equal "editor", membership.reload.role
      assert invitation.reload.accepted_at.present?
    end
  end
end