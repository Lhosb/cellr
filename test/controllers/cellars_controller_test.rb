require "test_helper"

class CellarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "index shows pending invitations for current user" do
    inviter = User.create!(email: "inviter-cellars@example.com", password: "Password123!", password_confirmation: "Password123!")
    cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

    CellarInvitation.create!(
      cellar:,
      invited_by: inviter,
      email: @user.email,
      role: :editor
    )

    get cellars_path

    assert_response :ok
    assert_match cellar.name, response.body
    assert_match "Pending Invitations", response.body
    assert_match "Accept", response.body
  end

  test "index does not show invitations for other users" do
    inviter = User.create!(email: "inviter-other@example.com", password: "Password123!", password_confirmation: "Password123!")
    cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

    CellarInvitation.create!(
      cellar:,
      invited_by: inviter,
      email: "someone-else@example.com",
      role: :viewer
    )

    get cellars_path

    assert_response :ok
    assert_no_match "Pending Invitations", response.body
  end

  test "index does not show already accepted invitations" do
    inviter = User.create!(email: "inviter-accepted@example.com", password: "Password123!", password_confirmation: "Password123!")
    cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

    CellarInvitation.create!(
      cellar:,
      invited_by: inviter,
      email: @user.email,
      role: :viewer,
      accepted_at: Time.current
    )

    get cellars_path

    assert_response :ok
    assert_no_match "Pending Invitations", response.body
  end

  test "accept invitation from cellars page creates membership" do
    inviter = User.create!(email: "inviter-accept@example.com", password: "Password123!", password_confirmation: "Password123!")
    cellar = inviter.cellar_memberships.find_by!(role: :owner).cellar

    invitation = CellarInvitation.create!(
      cellar:,
      invited_by: inviter,
      email: @user.email,
      role: :editor,
      token: "cellars-page-accept"
    )

    assert_difference("CellarMembership.count", 1) do
      post accept_cellar_invitation_path(invitation.token)
    end

    assert_redirected_to cellar_path(cellar)
    membership = CellarMembership.find_by!(cellar:, user: @user)
    assert_equal "editor", membership.role
  end

  test "show filters wines by tag" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar

    summer_wine = cellar.wines.create!(winery: "Domaine Tempier", wine_name: "Bandol Rose", vintage: 2022)
    winter_wine = cellar.wines.create!(winery: "Ridge", wine_name: "Monte Bello", vintage: 2020)

    summer_tag = cellar.tags.create!(name: "summer")
    winter_tag = cellar.tags.create!(name: "winter")
    summer_wine.tags << summer_tag
    winter_wine.tags << winter_tag

    get cellar_path(cellar), params: { tag: " SUMMER " }

    assert_response :ok
    assert_match summer_wine.wine_name, response.body
    assert_no_match winter_wine.wine_name, response.body
  end
end
