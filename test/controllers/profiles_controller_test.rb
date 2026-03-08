require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "show renders profile" do
    get profile_path

    assert_response :success
    assert_match "Profile", response.body
  end

  test "update changes name and starts happy hour session" do
    patch profile_path, params: { user: { name: "Luke" }, drinking_status: "start" }

    assert_redirected_to profile_path
    assert_equal "Luke", @user.reload.name
    assert @user.in_active_drinking_session?
  end

  test "update can stop active happy hour session" do
    DrinkingSessions::Start.call(user: @user)

    patch profile_path, params: { user: { name: "Luke" }, drinking_status: "stop" }

    assert_redirected_to profile_path
    assert_equal "Luke", @user.reload.name
    assert_not @user.in_active_drinking_session?
  end
end
