class WinesController < ApplicationController
  def index
    @wines = Wines::FilterQuery.new(scope: Wine.all, params: filter_params).call
  end

  def create
    cellar = Cellar.find(params.require(:cellar_id))

    duplicates = Wine.duplicate_candidates_for(
      cellar:,
      winery: wine_params[:winery],
      wine_name: wine_params[:wine_name],
      vintage: wine_params[:vintage]
    )

    if duplicates.exists?
      render json: { error: "Duplicate candidates found", duplicates: duplicates.limit(5).as_json(only: [ :id, :winery, :wine_name, :vintage ]) }, status: :conflict
      return
    end

    wine = cellar.wines.create!(wine_params)
    render json: wine, status: :created
  end

  private

  def filter_params
    params.permit(:cellar_id, :q, :winery, :region, :wine_type, :tag)
  end

  def wine_params
    params.require(:wine).permit(:winery, :wine_name, :vintage, :varietal, :wine_type, :region, :bottle_size_ml, :purchase_price_cents)
  end
end
