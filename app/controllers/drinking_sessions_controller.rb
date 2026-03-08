class DrinkingSessionsController < ApplicationController
  def create
    DrinkingSessions::Start.call(user: current_user)

    redirect_to happy_hour_path, notice: "Happy Hour started"
  end

  def destroy
    stopped_session = DrinkingSessions::Stop.call(user: current_user)
    notice = stopped_session ? "Happy Hour stopped" : "No active Happy Hour session to stop"

    redirect_to happy_hour_path, notice:
  end
end
