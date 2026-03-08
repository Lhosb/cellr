class ProfilesController < ApplicationController
  def show
    @user = current_user
  end

  def update
    ActiveRecord::Base.transaction do
      current_user.update!(profile_params)

      case params[:drinking_status]
      when "start"
        DrinkingSessions::Start.call(user: current_user)
      when "stop"
        DrinkingSessions::Stop.call(user: current_user)
      end
    end

    redirect_to profile_path, notice: "Profile updated"
  rescue ActiveRecord::RecordInvalid
    @user = current_user
    render :show, status: :unprocessable_entity
  end

  private

  def profile_params
    params.require(:user).permit(:name)
  end
end
