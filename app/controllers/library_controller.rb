class LibraryController < ApplicationController
  def show
    @wine_totals = Library::WineTotalsQuery.new.call
    @winery_totals = Library::WineryTotalsQuery.new.call
    @selected_wine_id = Integer(params[:wine_id], exception: false)

    return if @selected_wine_id.blank?

    @selected_wine = Wine.find_by(id: @selected_wine_id)
    return if @selected_wine.blank?

    @wine_vintage_totals = Library::WineVintageBreakdownQuery.new.call(wine_id: @selected_wine.id)
  end
end
