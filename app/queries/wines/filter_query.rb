module Wines
  class FilterQuery
    def initialize(scope: Wine.all, params: {})
      @scope = scope
      @params = params
    end

    def call
      relation = @scope
      relation = relation.where(cellar_id: cellar_id) if cellar_id.present?
      relation = relation.search_text(query) if query.present?
      relation = relation.where("LOWER(normalized_winery) = ?", normalize(winery)) if winery.present?
      relation = relation.joins(:region_record).where(regions: { normalized_name: normalize(region) }) if region.present?
      relation = relation.where(wine_type:) if wine_type.present?
      relation = relation.joins(:tags).where(tags: { name: normalize(tag) }) if tag.present?

      relation.includes(:tags).distinct.reorder(created_at: :desc)
    end

    private

    def cellar_id
      @params[:cellar_id]
    end

    def query
      @params[:q]
    end

    def winery
      @params[:winery]
    end

    def region
      @params[:region]
    end

    def wine_type
      @params[:wine_type]
    end

    def tag
      @params[:tag]
    end

    def normalize(value)
      Wine.normalize_for_key(value)
    end
  end
end
