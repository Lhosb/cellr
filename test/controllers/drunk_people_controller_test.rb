require "test_helper"

class DrunkPeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "index lists only activated users who are drunk" do
    listed = User.create!(email: "listed@example.com", name: "Listed", password: "Password123!", password_confirmation: "Password123!", drunk: true)
    User.create!(email: "sober@example.com", name: "Sober", password: "Password123!", password_confirmation: "Password123!", drunk: false)
    User.create!(email: "inactive@example.com", name: "Inactive", drunk: true)

    get drunk_people_path

    assert_response :success
    assert_match listed.name, response.body
    assert_no_match "Sober", response.body
    assert_no_match "Inactive", response.body
  end

  test "index shows each user's most recently drunk wine and does not show email" do
    listed = User.create!(email: "listed@example.com", name: "Listed", password: "Password123!", password_confirmation: "Password123!", drunk: true)
    cellar = listed.default_cellar_or_fallback

    older = cellar.wines.create!(winery: winery_named("Producer A"), wine_name: "Old Bottle", vintage: 2018, state: :drunk)
    recent = cellar.wines.create!(winery: winery_named("Producer B"), wine_name: "New Bottle", vintage: 2021, state: :drunk)
    older.update!(updated_at: 2.days.ago)
    recent.update!(updated_at: 1.hour.ago)

    get drunk_people_path

    assert_response :success
    assert_match "Listed", response.body
    assert_match "New Bottle", response.body
    assert_no_match "Old Bottle", response.body
    assert_no_match "listed@example.com", response.body
  end
end
