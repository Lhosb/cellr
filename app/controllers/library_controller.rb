class LibraryController < ApplicationController
  def show
    # existing consumption-based lists (limit to user's context)
    @wine_totals = Library::WineTotalsQuery.new(user_id: current_user.id).call
    @winery_totals = Library::WineryTotalsQuery.new(user_id: current_user.id).call
    # New library overview and visual sections (always available)
    @overview = Library::OverviewQuery.new(user: current_user).call
    @by_type = Library::ByTypeQuery.new(user: current_user).call
    @top_cellared_wineries = Library::TopCellaredWineriesQuery.new(user: current_user).call(limit: 5)
    @vintage_distribution = Library::VintageDistributionQuery.new(user: current_user).call
    @top_cellared_wines = Library::TopCellaredWinesQuery.new(user: current_user).call(limit: 5)
    @active_sessions_count = HappyHour::ActiveSessionsQuery.new.call.count

    @selected_wine_id = Integer(params[:wine_id], exception: false)

    return if @selected_wine_id.blank?

    @selected_wine = Wine.find_by(id: @selected_wine_id)
    return if @selected_wine.blank?

    @wine_vintage_totals = Library::WineVintageBreakdownQuery.new.call(wine_id: @selected_wine.id)
  end
end
