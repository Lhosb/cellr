require "test_helper"

class DrinkingSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "create starts session and redirects to happy hour" do
    assert_difference("DrinkingSession.count", 1) do
      post drinking_session_path
    end

    assert_redirected_to happy_hour_path
    assert_match "Happy Hour started", flash[:notice]
  end

  test "destroy stops current session and redirects to happy hour" do
    DrinkingSessions::Start.call(user: @user)

    delete drinking_session_path

    assert_redirected_to happy_hour_path
    assert_match "Happy Hour stopped", flash[:notice]
    assert_nil @user.active_drinking_session
  end
end
