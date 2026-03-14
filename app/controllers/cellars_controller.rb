class CellarsController < ApplicationController
  before_action :set_cellar, only: [ :show, :settings, :update, :set_default, :destroy ]

  def index
    @cellars = accessible_cellars.includes(:owner).order(created_at: :desc)
    @user = current_user
    @pending_invitations = current_user.pending_invitations.includes(:cellar, :invited_by).order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @cellars }
    end
  end

  def show
    filtered_wines = Wines::FilterQuery.new(scope: @cellar.wines, params: filter_params).call
    filtered_wine_ids = filtered_wines.unscope(:order).select(:id)

    @cellar_entries = @cellar.cellar_entries
                            .where(wine_id: filtered_wine_ids)
                            .includes(wine: [ :winery, :region_record, :tags ])
                            .order(created_at: :desc, id: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @cellar }
    end
  end

  def settings
    load_sharing_context

    respond_to do |format|
      format.html
      format.json { render json: @cellar }
    end
  end

  def create
    cellar = Cellar.create!(name: params.require(:name), owner: current_user)
    CellarMembership.find_or_create_by!(cellar:, user: current_user) { |membership| membership.role = :owner }

    respond_to do |format|
      format.html { redirect_to cellar_path(cellar), notice: "Cellar created" }
      format.json { render json: cellar, status: :created }
    end
  end

  def update
    @cellar.update!(name: params.require(:name))

    respond_to do |format|
      format.html { redirect_to cellar_path(@cellar), notice: "Cellar updated" }
      format.json { render json: @cellar }
    end
  end

  def set_default
    Cellars::SetDefault.call(user: current_user, cellar: @cellar)

    respond_to do |format|
      format.html { redirect_to settings_cellar_path(@cellar), notice: "#{@cellar.name} is now your default cellar" }
      format.json { render json: @cellar }
    end
  end

  def destroy
    @cellar.destroy!

    respond_to do |format|
      format.html { redirect_to cellars_path, notice: "Cellar deleted" }
      format.json { head :no_content }
    end
  end

  private

  def filter_params
    params.permit(:q, :winery, :region, :wine_type, :tag)
  end

  def set_cellar
    # Allow global access for admin user defined by ADMIN_EMAIL env
    if ENV["ADMIN_EMAIL"].present? && current_user&.email == ENV["ADMIN_EMAIL"]
      @cellar = Cellar.find(params[:id])
    else
      @cellar = accessible_cellars.find(params[:id])
    end
  end

  def accessible_cellars
    Cellar.left_outer_joins(:cellar_memberships)
      .where("cellars.owner_id = :user_id OR cellar_memberships.user_id = :user_id", user_id: current_user.id)
      .distinct
  end

  def load_sharing_context
    @memberships = @cellar.cellar_memberships.includes(:user).order(created_at: :asc)
    @pending_invitations = @cellar.cellar_invitations.pending.order(created_at: :desc)

    current_membership = @memberships.find { |membership| membership.user_id == current_user.id }
    @can_manage_sharing = @cellar.owner_id == current_user.id || current_membership&.owner? || current_membership&.editor?
  end
end
