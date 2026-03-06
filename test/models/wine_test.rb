require "test_helper"

class WineTest < ActiveSupport::TestCase
  test "normalizes identity and builds canonical key" do
    cellar = build_cellar

    wine = cellar.wines.create!(
      winery: "  Domaine Tempier  ",
      wine_name: "  Bandol Rose  ",
      vintage: nil,
      region: "  Provence  "
    )

    assert_equal "Domaine Tempier", wine.winery
    assert_equal "Bandol Rose", wine.wine_name
    assert_equal "domaine tempier", wine.normalized_winery
    assert_equal "bandol rose", wine.normalized_wine_name
    assert_equal "domaine tempier|bandol rose|nv", wine.canonical_key
  end

  test "duplicate candidates returns exact canonical match first" do
    cellar = build_cellar
    existing = cellar.wines.create!(
      winery: "Domaine Tempier",
      wine_name: "Bandol Rose",
      vintage: 2022
    )

    result = Wine.duplicate_candidates_for(
      cellar:,
      winery: "  domaine tempier ",
      wine_name: " BANDOL   ROSE ",
      vintage: 2022
    )

    assert_equal [existing.id], result.pluck(:id)
  end

  test "duplicate candidates falls back to fuzzy search" do
    cellar = build_cellar
    fuzzy = cellar.wines.create!(
      winery: "Domaine Tempier",
      wine_name: "Bandol Rouge",
      vintage: 2021
    )

    result = Wine.duplicate_candidates_for(
      cellar:,
      winery: "Tempier",
      wine_name: "Bandol",
      vintage: 2022
    )

    assert_includes result.pluck(:id), fuzzy.id
  end
end