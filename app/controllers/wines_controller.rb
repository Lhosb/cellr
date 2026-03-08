class WinesController < ApplicationController
  before_action :load_cellar, only: [ :show, :create, :edit, :update, :destroy, :drink ]
  before_action :load_wine, only: [ :show, :edit, :update, :destroy, :drink ]

  def index
    @wines = Wines::FilterQuery.new(scope: Wine.all, params: filter_params).call.includes(:cellar)
  end

  def create
    attributes, tag_names = normalized_wine_payload

    wine = nil
    ActiveRecord::Base.transaction do
      wine = @cellar.wines.create!(attributes)
      assign_tags(wine, tag_names)
    end

    respond_to do |format|
      format.html { redirect_to cellar_wine_path(@cellar, wine), notice: "Wine added" }
      format.json { render json: wine, status: :created }
    end
  end

  def edit
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @wine }
    end
  end

  def destroy
    @wine.destroy!

    respond_to do |format|
      format.html { redirect_to cellar_path(@cellar), notice: "Wine deleted" }
      format.json { head :no_content }
    end
  end

  def drink
    Wines::TransitionState.new(wine: @wine, event: :drink, actor: current_user).call

    respond_to do |format|
      format.html { redirect_to cellar_wine_path(@cellar, @wine), notice: "Cheers! Wine marked as drunk" }
      format.json { render json: @wine, status: :ok }
    end
  end

  def update
    attributes, tag_names = normalized_wine_payload

    updated = false
    ActiveRecord::Base.transaction do
      updated = @wine.update(attributes)
      assign_tags(@wine, tag_names) if updated
    end

    if updated
      respond_to do |format|
        format.html { redirect_to cellar_wine_path(@cellar, @wine), notice: "Wine updated" }
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
    params.require(:wine).permit(:winery, :wine_name, :vintage, :varietal, :wine_type, :region, :bottle_size_ml, :purchase_price_cents, :purchase_price, :tag_list, :notes, :tasting_notes)
  end

  def normalized_wine_payload
    permitted = wine_params.to_h
    tag_list = permitted.delete("tag_list")

    # Resolve winery string to a Winery record
    winery_name = permitted.delete("winery")
    if winery_name.present?
      permitted["winery"] = Winery.find_or_create_normalized(winery_name)
    end

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
