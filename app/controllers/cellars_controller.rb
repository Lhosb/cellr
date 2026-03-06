class CellarsController < ApplicationController
  def index
    @cellars = Cellar.order(created_at: :desc)
    render json: @cellars
  end

  def show
    @cellar = Cellar.find(params[:id])
    render json: @cellar
  end

  def create
    owner = User.find(params.require(:owner_id))
    cellar = Cellar.create!(name: params.require(:name), owner: owner)
    CellarMembership.find_or_create_by!(cellar:, user: owner) { |membership| membership.role = :owner }
    render json: cellar, status: :created
  end

  def update
    cellar = Cellar.find(params[:id])
    cellar.update!(name: params.require(:name))
    render json: cellar
  end

  def destroy
    cellar = Cellar.find(params[:id])
    cellar.destroy!
    head :no_content
  end
end
