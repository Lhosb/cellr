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

  test "update changes name and drunk flag" do
    patch profile_path, params: { user: { name: "Luke", drunk: true } }

    assert_redirected_to profile_path
    assert_equal "Luke", @user.reload.name
    assert @user.drunk
  end
end
