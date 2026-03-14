class LibraryController < ApplicationController
  def show
    # scope param: 'global' (default) or 'user'
    requested_scope = params[:scope].to_s == "user" ? :user : :global

    # consumption-based lists: scoped to user when requested, otherwise global
    if requested_scope == :user && current_user.present?
      @wine_totals = Library::WineTotalsQuery.new(user_id: current_user.id).call
      @winery_totals = Library::WineryTotalsQuery.new(user_id: current_user.id).call
    else
      @wine_totals = Library::WineTotalsQuery.new.call
      @winery_totals = Library::WineryTotalsQuery.new.call
    end

    # New library overview and visual sections
    if requested_scope == :user && current_user.present?
      @overview = Library::OverviewQuery.new(user: current_user).call
      @by_type = Library::ByTypeQuery.new(user: current_user).call
      @top_cellared_wineries = Library::TopCellaredWineriesQuery.new(user: current_user).call(limit: 5)
      @vintage_distribution = Library::VintageDistributionQuery.new(user: current_user).call
      @top_cellared_wines = Library::TopCellaredWinesQuery.new(user: current_user).call(limit: 5)
      @active_sessions_count = HappyHour::ActiveSessionsQuery.new.call.count
    else
      @overview = Library::OverviewQuery.new.call
      @by_type = Library::ByTypeQuery.new.call
      @top_cellared_wineries = Library::TopCellaredWineriesQuery.new.call(limit: 5)
      @vintage_distribution = Library::VintageDistributionQuery.new.call
      @top_cellared_wines = Library::TopCellaredWinesQuery.new.call(limit: 5)
      @active_sessions_count = HappyHour::ActiveSessionsQuery.new.call.count
    end

    @view_scope = requested_scope

    @selected_wine_id = Integer(params[:wine_id], exception: false)

    return if @selected_wine_id.blank?

    @selected_wine = Wine.find_by(id: @selected_wine_id)
    return if @selected_wine.blank?

    @wine_vintage_totals = Library::WineVintageBreakdownQuery.new.call(wine_id: @selected_wine.id)
  end
end
