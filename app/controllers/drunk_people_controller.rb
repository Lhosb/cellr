class DrunkPeopleController < ApplicationController
  def index
    @users = User.activated.currently_drunk.order(:name, :email)
    @latest_drunk_wine_by_user_id = load_latest_drunk_wines(@users)
  end

  private

  def load_latest_drunk_wines(users)
    return {} if users.empty?

    Wine.drunk
      .joins(cellar: :cellar_memberships)
      .where(cellar_memberships: { user_id: users.map(&:id) })
      .includes(:winery)
      .select("DISTINCT ON (cellar_memberships.user_id) cellar_memberships.user_id AS drunk_user_id, wines.*")
      .order(Arel.sql("cellar_memberships.user_id, wines.updated_at DESC, wines.id DESC"))
      .index_by { |wine| wine.attributes.fetch("drunk_user_id").to_i }
  end
end
