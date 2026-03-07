class WinesController < ApplicationController
  before_action :load_cellar, only: [ :create, :edit, :update ]
  before_action :load_wine, only: [ :edit, :update ]

  def index
    @wines = Wines::FilterQuery.new(scope: Wine.all, params: filter_params).call.includes(:cellar)
  end

  def create
    attributes, tag_names = normalized_wine_payload

    duplicates = Wine.duplicate_candidates_for(
      cellar: @cellar,
      winery: attributes["winery"],
      wine_name: attributes["wine_name"],
      vintage: attributes["vintage"]
    )

    if duplicates.exists?
      respond_to do |format|
        format.html { redirect_to cellar_path(@cellar), alert: "Duplicate candidates found. Wine was not added." }
        format.json { render json: { error: "Duplicate candidates found", duplicates: duplicates.limit(5).as_json(only: [ :id, :winery, :wine_name, :vintage ]) }, status: :conflict }
      end
      return
    end

    wine = nil
    ActiveRecord::Base.transaction do
      wine = @cellar.wines.create!(attributes)
      assign_tags(wine, tag_names)
    end

    respond_to do |format|
      format.html { redirect_to cellar_path(@cellar), notice: "Wine added" }
      format.json { render json: wine, status: :created }
    end
  end

  def edit
  end

  def update
    attributes, tag_names = normalized_wine_payload

    duplicates = Wine.duplicate_candidates_for(
      cellar: @cellar,
      winery: attributes["winery"],
      wine_name: attributes["wine_name"],
      vintage: attributes["vintage"]
    ).where.not(id: @wine.id)

    if duplicates.exists?
      respond_to do |format|
        format.html { redirect_to edit_cellar_wine_path(@cellar, @wine), alert: "Duplicate candidates found. Wine was not updated." }
        format.json { render json: { error: "Duplicate candidates found", duplicates: duplicates.limit(5).as_json(only: [ :id, :winery, :wine_name, :vintage ]) }, status: :conflict }
      end
      return
    end

    updated = false
    ActiveRecord::Base.transaction do
      updated = @wine.update(attributes)
      assign_tags(@wine, tag_names) if updated
    end

    if updated
      respond_to do |format|
        format.html { redirect_to cellar_path(@cellar), notice: "Wine updated" }
        format.json { render json: @wine, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @wine.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def filter_params
    params.permit(:cellar_id, :q, :winery, :region, :wine_type, :tag)
  end

  def wine_params
    params.require(:wine).permit(:winery, :wine_name, :vintage, :varietal, :wine_type, :region, :bottle_size_ml, :purchase_price_cents, :purchase_price, :tag_list)
  end

  def normalized_wine_payload
    permitted = wine_params.to_h
    tag_list = permitted.delete("tag_list")

    if permitted["purchase_price"].present?
      dollars = BigDecimal(permitted.delete("purchase_price").to_s)
      permitted["purchase_price_cents"] = (dollars * 100).round(0).to_i
    else
      permitted.delete("purchase_price")
    end

    [ permitted, parse_tag_names(tag_list) ]
  end

  def parse_tag_names(value)
    value.to_s.split(",").map { |name| name.strip.downcase }.reject(&:blank?).uniq
  end

  def assign_tags(wine, tag_names)
    tags = tag_names.map { |name| @cellar.tags.find_or_create_by!(name:) }
    wine.tags = tags
  end

  def load_cellar
    @cellar = accessible_cellars.find(params.require(:cellar_id))
  end

  def load_wine
    @wine = @cellar.wines.find(params[:id])
  end

  def accessible_cellars
    Cellar.left_outer_joins(:cellar_memberships)
      .where("cellars.owner_id = :user_id OR cellar_memberships.user_id = :user_id", user_id: current_user.id)
      .distinct
  end
end
