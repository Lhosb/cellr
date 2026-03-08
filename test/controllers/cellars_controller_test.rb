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

    summer_wine = cellar.wines.create!(winery: winery_named("Domaine Tempier"), wine_name: "Bandol Rose", vintage: 2022)
    winter_wine = cellar.wines.create!(winery: winery_named("Ridge"), wine_name: "Monte Bello", vintage: 2020)

    summer_tag = cellar.tags.create!(name: "summer")
    winter_tag = cellar.tags.create!(name: "winter")
    summer_wine.tags << summer_tag
    winter_wine.tags << winter_tag

    get cellar_path(cellar), params: { tag: " SUMMER " }

    assert_response :ok
    assert_match summer_wine.wine_name, response.body
    assert_no_match winter_wine.wine_name, response.body
  end

  test "show page links to settings and hides management forms" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar

    get cellar_path(cellar)

    assert_response :ok
    assert_match "Settings", response.body
    assert_no_match "Edit Cellar Name", response.body
    assert_no_match "Invite People", response.body
  end

  test "show separates in-cellar and past wines by state" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar
    in_cellar_wine = cellar.wines.create!(winery: winery_named("Coche-Dury"), wine_name: "Bourgogne", vintage: 2021, state: :in_cellar)
    past_wine = cellar.wines.create!(winery: winery_named("Ridge"), wine_name: "Monte Bello", vintage: 2018, state: :drunk, drunk_at: Time.current)

    get cellar_path(cellar)

    assert_response :ok
    assert_select "h2", text: "In the cellar"
    assert_select "h2", text: "Past wines"
    assert_select "h3", text: in_cellar_wine.wine_name, count: 1
    assert_select "h3", text: past_wine.wine_name, count: 1

    in_cellar_section = response.body.split("<h2 class=\"font-display text-2xl font-bold italic\">In the cellar</h2>", 2).last
    in_cellar_section = in_cellar_section.split("<h2 class=\"font-display text-2xl font-bold italic\">Past wines</h2>", 2).first

    past_wines_section = response.body.split("<h2 class=\"font-display text-2xl font-bold italic\">Past wines</h2>", 2).last

    assert_includes in_cellar_section, in_cellar_wine.wine_name
    assert_not_includes in_cellar_section, past_wine.wine_name
    assert_includes past_wines_section, past_wine.wine_name
  end

  test "settings page shows rename and invite management" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar

    get settings_cellar_path(cellar)

    assert_response :ok
    assert_match "Cellar Settings", response.body
    assert_match "Edit Cellar Name", response.body
    assert_match "Invite People", response.body
  end

  test "update renames cellar" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar

    patch cellar_path(cellar), params: { name: "Weekend Cellar" }

    assert_redirected_to cellar_path(cellar)
    assert_equal "Weekend Cellar", cellar.reload.name
  end

  test "set_default marks cellar as default for current user" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar

    patch set_default_cellar_path(cellar)

    assert_redirected_to settings_cellar_path(cellar)
    membership = @user.cellar_memberships.find_by!(cellar: cellar)
    assert membership.default?
  end

  test "set_default clears prior default and sets new one" do
    first_cellar = @user.cellar_memberships.find_by!(role: :owner).cellar
    Cellars::SetDefault.call(user: @user, cellar: first_cellar)

    second_cellar = Cellar.create!(name: "Second", owner: @user)
    CellarMembership.create!(cellar: second_cellar, user: @user, role: :owner)

    patch set_default_cellar_path(second_cellar)

    assert_redirected_to settings_cellar_path(second_cellar)
    refute @user.cellar_memberships.find_by!(cellar: first_cellar).default?
    assert @user.cellar_memberships.find_by!(cellar: second_cellar).default?
  end

  test "settings shows default cellar badge when cellar is default" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar
    Cellars::SetDefault.call(user: @user, cellar: cellar)

    get settings_cellar_path(cellar)

    assert_response :ok
    assert_match "Default", response.body
  end
end
