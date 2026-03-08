require "test_helper"

class HappyHourControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "show renders happy hour page and empty state" do
    get happy_hour_path

    assert_response :success
    assert_match "Happy Hour", response.body
    assert_match "No active Happy Hour sessions right now.", response.body
  end

  test "show displays active sessions and currently drinking indicator" do
    other_user = build_user
    now = Time.current
    session = DrinkingSessions::Start.call(user: other_user, time: now)
    wine = other_user.default_cellar_or_fallback.wines.create!(
      winery: winery_named("Roulot"),
      wine_name: "Meursault",
      vintage: 2020
    )
    DrinkingRecords::Create.call(user: other_user, cellar_entry: wine, consumed_at: now + 1.minute)

    get happy_hour_path

    assert_response :success
    assert_match(other_user.name.presence || "Mystery Sipper", response.body)
    assert_match("Meursault", response.body)
    assert_match("Currently drinking", response.body)
    assert_not_nil session.reload
  end
end
