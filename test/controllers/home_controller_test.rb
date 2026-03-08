require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "redirects to default cellar when one exists" do
    cellar = @user.cellar_memberships.find_by!(role: :owner).cellar
    Cellars::SetDefault.call(user: @user, cellar: cellar)

    get root_path

    assert_redirected_to cellar_path(cellar)
  end

  test "redirects to cellars index when no default cellar" do
    @user.cellar_memberships.update_all(default: false)

    get root_path

    assert_redirected_to cellars_path
  end
end
