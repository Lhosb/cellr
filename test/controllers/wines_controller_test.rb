require "test_helper"

class WinesControllerTest < ActionDispatch::IntegrationTest
  test "create returns created json when no duplicate exists" do
    cellar = build_cellar

    assert_difference("Wine.count", 1) do
      post cellar_wines_path(cellar), params: {
        wine: {
          winery: "Domaine Tempier",
          wine_name: "Bandol Rose",
          vintage: 2022,
          region: "Provence",
          wine_type: "rosé"
        }
      }
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Domaine Tempier", body["winery"]
    assert_equal "Bandol Rose", body["wine_name"]
  end

  test "create returns conflict and duplicates when canonical duplicate exists" do
    cellar = build_cellar
    existing = cellar.wines.create!(winery: "Domaine Tempier", wine_name: "Bandol Rose", vintage: 2022)

    assert_no_difference("Wine.count") do
      post cellar_wines_path(cellar), params: {
        wine: {
          winery: "  domaine tempier ",
          wine_name: "BANDOL ROSE",
          vintage: 2022
        }
      }
    end

    assert_response :conflict
    body = JSON.parse(response.body)
    assert_equal "Duplicate candidates found", body["error"]
    assert_equal existing.id, body.fetch("duplicates").first.fetch("id")
  end
end