class HappyHourController < ApplicationController
  def show
    @active_sessions = HappyHour::ActiveSessionsQuery.new.call
    @current_session = current_user.active_drinking_session
    @available_wines = accessible_wines.order(created_at: :desc).limit(100)
  end

  private

  def accessible_wines
    Wine.joins(:cellar)
      .left_outer_joins(cellar: :cellar_memberships)
      .where("cellars.owner_id = :user_id OR cellar_memberships.user_id = :user_id", user_id: current_user.id)
      .includes(:winery, :region_record)
      .distinct
  end
end
