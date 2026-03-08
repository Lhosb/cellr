class HomeController < ApplicationController
  def show
    cellar = current_user.default_cellar
    if cellar
      redirect_to cellar_path(cellar)
    else
      redirect_to cellars_path
    end
  end
end
