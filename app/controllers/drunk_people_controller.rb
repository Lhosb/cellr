class DrunkPeopleController < ApplicationController
  def index
    redirect_to happy_hour_path
  end
end
