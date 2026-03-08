require "test_helper"

class DrunkPeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "index redirects to happy hour page" do
    get drunk_people_path

    assert_redirected_to happy_hour_path
  end
end
