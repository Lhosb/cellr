module Admin
  class CellarsController < ApplicationController
    before_action :require_admin!

    def index
      @cellars = Cellar.includes(:owner, :cellar_memberships).order(created_at: :desc)
    end

    private

    def require_admin!
      admin_email = ENV["ADMIN_EMAIL"]
      unless admin_email.present? && current_user && current_user.email == admin_email
        redirect_to(root_path, alert: "Not authorized")
      end
    end
  end
end
