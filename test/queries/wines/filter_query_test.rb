require "test_helper"

module Wines
  class FilterQueryTest < ActiveSupport::TestCase
    test "filters by cellar id" do
      cellar_a = build_cellar(name: "A")
      cellar_b = build_cellar(name: "B")

      keep = cellar_a.wines.create!(winery: "Alpha", wine_name: "One", vintage: 2020)
      cellar_b.wines.create!(winery: "Beta", wine_name: "Two", vintage: 2020)

      result = FilterQuery.new(scope: Wine.all, params: { cellar_id: cellar_a.id }).call

      assert_equal [ keep.id ], result.to_a.map(&:id)
    end

    test "filters by normalized winery and tag" do
      cellar = build_cellar

      tagged = cellar.wines.create!(winery: "Domaine Tempier", wine_name: "Bandol Rose", vintage: 2022)
      untagged = cellar.wines.create!(winery: "Domaine Tempier", wine_name: "Bandol Rouge", vintage: 2021)
      tag = cellar.tags.create!(name: "summer")
      tagged.tags << tag

      result = FilterQuery.new(
        scope: Wine.all,
        params: { cellar_id: cellar.id, winery: "  DOMAINE TEMPIER ", tag: " SUMMER " }
      ).call

      result_ids = result.to_a.map(&:id)

      assert_equal [ tagged.id ], result_ids
      refute_includes result_ids, untagged.id
    end

    test "searches notes and tasting notes text" do
      cellar = build_cellar

      note_match = cellar.wines.create!(
        winery: "Producer A",
        wine_name: "Reserve",
        vintage: 2021,
        notes: "Hold for anniversary dinner",
        tasting_notes: "Cherry, cedar, spice"
      )
      cellar.wines.create!(
        winery: "Producer B",
        wine_name: "Village",
        vintage: 2020,
        notes: "Weeknight bottle",
        tasting_notes: "Lemon zest"
      )

      result = FilterQuery.new(scope: Wine.all, params: { cellar_id: cellar.id, q: "anniversary" }).call

      assert_equal [ note_match.id ], result.to_a.map(&:id)
    end
  end
end
