class WinesController < ApplicationController
  before_action :load_cellar, only: [ :show, :create, :edit, :update, :destroy, :drink, :re_add ]
  before_action :load_wine, only: [ :show, :edit, :update, :destroy, :drink, :re_add ]

  def index
    @wines = Wines::FilterQuery.new(scope: Wine.all, params: filter_params).call.includes(:winery, :region_record, :cellar_entries)
  end

  def create
    wine_attributes, cellar_entry_attributes, tag_names = normalized_wine_payload

    wine = nil
    ActiveRecord::Base.transaction do
      wine = find_or_initialize_global_wine(wine_attributes)
      wine.assign_attributes(wine_attributes)
      wine.save!
      sync_cellar_entry!(wine, cellar_entry_attributes)
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
    @cellar.cellar_entries.find_by(wine_id: @wine.id)&.destroy!
    @wine.destroy! if @wine.cellar_entries.reload.none?

    respond_to do |format|
      format.html { redirect_to cellar_path(@cellar), notice: "Wine deleted" }
      format.json { head :no_content }
    end
  end

  def drink
    Wines::TransitionState.new(wine: @wine, event: :drink, actor: current_user).call

    respond_to do |format|
      format.html { redirect_to happy_hour_path, notice: "Cheers! Wine marked as drunk" }
      format.json { render json: @wine, status: :ok }
    end
  end

  def re_add
    unless @wine.drunk?
      respond_to do |format|
        format.html { redirect_to cellar_wine_path(@cellar, @wine), alert: "Only drunk wines can be re-added" }
        format.json { render json: { error: "Only drunk wines can be re-added" }, status: :unprocessable_entity }
      end
      return
    end

    re_added_wine = Wines::TransitionState.new(
      wine: @wine,
      event: :restore,
      actor: current_user,
      context: { cellar: @cellar }
    ).call

    respond_to do |format|
      format.html { redirect_to cellar_wine_path(@cellar, re_added_wine), notice: "Wine re-added to cellar" }
      format.json { render json: re_added_wine, status: :created }
    end
  end

  def update
    wine_attributes, cellar_entry_attributes, tag_names = normalized_wine_payload

    updated = false
    ActiveRecord::Base.transaction do
      target_wine = find_or_initialize_global_wine(wine_attributes)

      if target_wine.persisted? && target_wine.id != @wine.id
        target_wine.update!(wine_attributes)
        cellar_entry = @cellar.cellar_entries.find_by(wine_id: @wine.id)
        cellar_entry&.update!(wine: target_wine)
        sync_cellar_entry!(target_wine, cellar_entry_attributes)
        assign_tags(target_wine, tag_names)
        @wine.destroy! if @wine.cellar_entries.reload.none?
        @wine = target_wine
        updated = true
      else
        updated = @wine.update(wine_attributes)
        if updated
          sync_cellar_entry!(@wine, cellar_entry_attributes)
          assign_tags(@wine, tag_names)
        end
      end
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
    winery = winery_name.present? ? Winery.find_or_create_normalized(winery_name) : nil

    region_name = permitted.delete("region")
    region_record = region_name.present? ? Region.find_or_create_normalized(region_name) : Region.unknown

    purchase_price_cents = permitted.delete("purchase_price_cents")

    if permitted["purchase_price"].present?
      dollars = BigDecimal(permitted.delete("purchase_price").to_s)
      purchase_price_cents = (dollars * 100).round(0).to_i
    else
      permitted.delete("purchase_price")
    end

    purchase_price_cents = purchase_price_cents.present? ? purchase_price_cents.to_i : 0

    wine_attributes = {
      winery:,
      name: permitted.delete("wine_name"),
      varietal: permitted.delete("varietal"),
      wine_type: permitted.delete("wine_type"),
      region_id: region_record.id,
      notes: permitted["notes"],
      tasting_notes: permitted["tasting_notes"]
    }

    cellar_entry_attributes = {
      vintage: permitted.delete("vintage"),
      bottle_size_ml: permitted.delete("bottle_size_ml"),
      notes: permitted.delete("notes"),
      tasting_notes: permitted.delete("tasting_notes"),
      purchase_price_cents:
    }

    [ wine_attributes, cellar_entry_attributes, parse_tag_names(tag_list) ]
  end

  def sync_cellar_entry!(wine, cellar_entry_attributes)
    cellar_entry = @cellar.cellar_entries.find_or_initialize_by(wine_id: wine.id)

    attributes = cellar_entry_attributes.compact
    if cellar_entry_attributes.key?(:drunk_at) && cellar_entry_attributes[:drunk_at].nil?
      attributes[:drunk_at] = nil
    end

    cellar_entry.assign_attributes(attributes)
    cellar_entry.save!
  end

  def find_or_initialize_global_wine(attributes)
    winery = attributes.fetch(:winery)
    normalized_name = Wine.normalize_for_key(attributes[:name])
    normalized_varietal = Wine.normalize_for_key(attributes[:varietal])
    normalized_wine_type = Wine.normalize_for_key(attributes[:wine_type])

    scope = Wine.where(winery_id: winery.id)
                .where("LOWER(name) = ?", normalized_name)
                .where("COALESCE(LOWER(varietal), '') = ?", normalized_varietal)
                .where("COALESCE(LOWER(wine_type), '') = ?", normalized_wine_type)

    scope.first_or_initialize
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
    @wine = @cellar.wines.distinct.find(params[:id])
  end

  def accessible_cellars
    Cellar.left_outer_joins(:cellar_memberships)
      .where("cellars.owner_id = :user_id OR cellar_memberships.user_id = :user_id", user_id: current_user.id)
      .distinct
  end
end
