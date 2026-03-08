require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "show renders wine and winery totals" do
    winery = winery_named("Library Winery")
    wine = Wine.create!(winery:, name: "Troublemaker")
    cellar_entry = CellarEntry.create!(cellar: build_cellar(owner: @user), wine:, vintage: 2020)

    DrinkingRecord.create!(
      drinking_session: build_session(@user),
      cellar_entry:,
      quantity: 3,
      consumed_at: Time.current
    )

    get library_path

    assert_response :ok
    assert_match "Library", response.body
    assert_match "Bottles Drank by Wine", response.body
    assert_match "Bottles Drank by Winery", response.body
    assert_match "Troublemaker", response.body
    assert_match "Library Winery", response.body
    assert_no_match "Unknown / NV", response.body
  end

  test "show renders vintage drill-down for selected wine" do
    winery = winery_named("Vintage Winery")
    wine = Wine.create!(winery:, name: "Split")
    vintage_entry = CellarEntry.create!(cellar: build_cellar(owner: @user), wine:, vintage: 2021)
    unknown_entry = CellarEntry.create!(cellar: build_cellar(owner: build_user), wine:, vintage: nil)

    DrinkingRecord.create!(drinking_session: build_session(@user), cellar_entry: vintage_entry, quantity: 2, consumed_at: Time.current)
    DrinkingRecord.create!(drinking_session: build_session(build_user), cellar_entry: unknown_entry, quantity: 1, consumed_at: Time.current)

    get library_path, params: { wine_id: wine.id }

    assert_response :ok
    assert_match "Vintage Breakdown", response.body
    assert_match "2021", response.body
    assert_match "Unknown / NV", response.body
  end

  private

  def build_session(user)
    DrinkingSession.create!(
      user:,
      date: Date.current,
      started_at: Time.current,
      last_activity_at: Time.current
    )
  end
end
