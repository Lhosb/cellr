require "test_helper"

class DrinkingRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "create logs drink and redirects to happy hour" do
    wine = @user.default_cellar_or_fallback.wines.create!(
      winery: winery_named("Ridge"),
      wine_name: "Lytton Springs",
      vintage: 2021
    )

    assert_difference("DrinkingRecord.count", 1) do
      post drinking_records_path, params: {
        drinking_record: {
          cellar_entry_id: wine.id,
          quantity: 1,
          tasting_notes: "Pepper and blackberry"
        }
      }
    end

    assert_redirected_to happy_hour_path
    assert_match "Drink logged", flash[:notice]
  end
end
