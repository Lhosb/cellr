require "test_helper"

class WinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as
  end

  test "create returns created json when no duplicate exists" do
    cellar = build_cellar(owner: @user)

    assert_difference("Wine.count", 1) do
      post cellar_wines_path(cellar), params: {
        wine: {
          winery: "Domaine Tempier",
          wine_name: "Bandol Rose",
          vintage: 2022,
          region: "Provence",
          wine_type: "rosé",
          notes: "Save for summer dinner",
          tasting_notes: "Strawberry, citrus, saline finish"
        }
      }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Bandol Rose", body["wine_name"]
    assert_equal "Save for summer dinner", body["notes"]
    assert_equal "Strawberry, citrus, saline finish", body["tasting_notes"]
  end

  test "create reuses existing global wine identity in the same cellar" do
    cellar = build_cellar(owner: @user)
    cellar.wines.create!(winery: winery_named("Domaine Tempier"), wine_name: "Bandol Rose", vintage: 2022)

    assert_no_difference("Wine.count") do
      post cellar_wines_path(cellar), params: {
        wine: {
          winery: "  domaine tempier ",
          wine_name: "BANDOL ROSE",
          vintage: 2022
        }
      }, as: :json
    end

    assert_response :created
  end

  test "edit renders successfully" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Arnot-Roberts"), wine_name: "Syrah", vintage: 2021)

    get edit_cellar_wine_path(cellar, wine)

    assert_response :success
  end

  test "update returns ok json when wine updates" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Arnot-Roberts"), wine_name: "Syrah", vintage: 2021)

    patch cellar_wine_path(cellar, wine), params: {
      wine: {
        winery: "Arnot-Roberts",
        wine_name: "Syrah Que Syrah",
        vintage: 2022,
        region: "Sonoma",
        varietal: "Syrah",
        bottle_size_ml: 750,
        purchase_price_cents: 4900,
        notes: "Decant 45 minutes",
        tasting_notes: "Blackberry, pepper, long finish"
      }
    }, as: :json

    assert_response :ok
    assert_equal "Syrah Que Syrah", wine.reload.wine_name
    assert_equal "Decant 45 minutes", wine.notes
    assert_equal "Blackberry, pepper, long finish", wine.tasting_notes
  end

  test "update allows updating wine to match another existing wine" do
    cellar = build_cellar(owner: @user)
    existing = cellar.wines.create!(winery: winery_named("Domaine Tempier"), wine_name: "Bandol Rose", vintage: 2022)
    wine = cellar.wines.create!(winery: winery_named("Different"), wine_name: "Label", vintage: 2020)

    patch cellar_wine_path(cellar, wine), params: {
      wine: {
        winery: "domaine tempier",
        wine_name: "BANDOL ROSE",
        vintage: 2022
      }
    }, as: :json

    assert_response :ok
    matched_ids = cellar.wines.joins(:winery)
                       .where("wineries.normalized_name = ?", "domaine tempier")
                       .where("LOWER(wines.name) = ?", "bandol rose")
                       .pluck(:id)
    assert_equal [ existing.id ], matched_ids
  end

  test "create assigns comma-separated tags" do
    cellar = build_cellar(owner: @user)

    assert_difference("Wine.count", 1) do
      post cellar_wines_path(cellar), params: {
        wine: {
          winery: "Domaine Tempier",
          wine_name: "Bandol Rose",
          vintage: 2022,
          tag_list: "Date Night, gift, date night"
        }
      }, as: :json
    end

    assert_response :created
    wine = cellar.wines.order(created_at: :desc).first
    assert_equal [ "date night", "gift" ], wine.tags.order(:name).pluck(:name)
  end

  test "update replaces tag list" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Arnot-Roberts"), wine_name: "Syrah", vintage: 2021)
    wine.tags << cellar.tags.create!(name: "old")

    patch cellar_wine_path(cellar, wine), params: {
      wine: {
        winery: "Arnot-Roberts",
        wine_name: "Syrah",
        vintage: 2021,
        tag_list: "new, special"
      }
    }, as: :json

    assert_response :ok
    assert_equal [ "new", "special" ], wine.reload.tags.order(:name).pluck(:name)
  end

  # ── Show ──

  test "show renders the wine detail page" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Ridge"), wine_name: "Monte Bello", vintage: 2019)

    get cellar_wine_path(cellar, wine)

    assert_response :success
    assert_select "h1", /Monte Bello/
  end

  test "show renders json for api requests" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Ridge"), wine_name: "Monte Bello", vintage: 2019)

    get cellar_wine_path(cellar, wine), as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "Monte Bello", body["wine_name"]
  end

  # ── Destroy ──

  test "destroy deletes the wine and redirects to cellar" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Krug"), wine_name: "Grande Cuvée", vintage: 2010)

    assert_difference("Wine.count", -1) do
      delete cellar_wine_path(cellar, wine)
    end

    assert_redirected_to cellar_path(cellar)
  end

  test "destroy returns no content for json" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Krug"), wine_name: "Grande Cuvée", vintage: 2010)

    assert_difference("Wine.count", -1) do
      delete cellar_wine_path(cellar, wine), as: :json
    end

    assert_response :no_content
  end

  # ── Drink ──

  test "drink via turbo_stream transitions wine to drunk and does not raise" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Domaine Leroy"), wine_name: "Musigny", vintage: 2015)

    assert_difference("DrinkingRecord.count", 1) do
      patch drink_cellar_wine_path(cellar, wine),
        headers: { "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }
    end

    wine.reload
    assert_equal "drunk", wine.state
    assert_redirected_to happy_hour_path
  end

  test "drink transitions wine to drunk state and records drunk_at" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Domaine Leroy"), wine_name: "Musigny", vintage: 2015)

    assert_equal "in_cellar", wine.state
    assert_nil wine.drunk_at

    assert_difference("DrinkingRecord.count", 1) do
      patch drink_cellar_wine_path(cellar, wine)
    end

    assert_redirected_to happy_hour_path
    wine.reload
    assert_equal "drunk", wine.state
    assert_not_nil wine.drunk_at
    assert_in_delta Time.current, wine.drunk_at, 5.seconds

    session = @user.active_drinking_session
    assert_not_nil session
    assert_equal cellar.cellar_entries.find_by(wine_id: wine.id)&.id, session.drinking_records.order(:created_at).last.cellar_entry_id
  end

  test "re_add reopens cellar entry without creating duplicate global wine" do
    cellar = build_cellar(owner: @user)
    drunk_wine = cellar.wines.create!(winery: winery_named("Domaine Leroy"), wine_name: "Musigny", vintage: 2015)

    assert_difference("DrinkingRecord.count", 1) do
      patch drink_cellar_wine_path(cellar, drunk_wine)
    end

    assert_equal "drunk", drunk_wine.reload.state
    original_record_count = DrinkingRecord.count

    assert_no_difference("Wine.count") do
      post re_add_cellar_wine_path(cellar, drunk_wine)
    end

    assert_redirected_to cellar_wine_path(cellar, drunk_wine)

    drunk_wine.reload
    assert_equal "in_cellar", drunk_wine.state
    assert_nil drunk_wine.drunk_at
    assert_equal original_record_count, DrinkingRecord.count

    entries = cellar.cellar_entries.where(wine_id: drunk_wine.id).order(:created_at)
    assert_equal 2, entries.count

    past_entry = entries.find { |entry| entry.drunk? }
    in_cellar_entry = entries.find { |entry| entry.in_cellar? }

    assert_not_nil past_entry
    assert_not_nil in_cellar_entry
    assert_not_nil past_entry.drunk_at
    assert_nil in_cellar_entry.drunk_at
  end

  test "re_add rejects wines that are already in cellar" do
    cellar = build_cellar(owner: @user)
    wine = cellar.wines.create!(winery: winery_named("Domaine Leroy"), wine_name: "Musigny", vintage: 2015)

    assert_no_difference("Wine.count") do
      post re_add_cellar_wine_path(cellar, wine)
    end

    assert_redirected_to cellar_wine_path(cellar, wine)
    assert_match "Only drunk wines can be re-added", flash[:alert]
  end
end
