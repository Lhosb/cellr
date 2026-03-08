class ProfilesController < ApplicationController
  def show
    @user = current_user
  end

  def update
    current_user.update!(profile_params)
    publish_drunk_announcement(current_user) if current_user.saved_change_to_drunk? && current_user.drunk?
    redirect_to profile_path, notice: "Profile updated"
  rescue ActiveRecord::RecordInvalid
    @user = current_user
    render :show, status: :unprocessable_entity
  end

  private

  def profile_params
    params.require(:user).permit(:name, :drunk)
  end

  # TODO: implement drunk announcement broadcast (ActionCable / Turbo Stream)
  def publish_drunk_announcement(user)
    Rails.logger.info "[DrunkAnnouncement] #{user.email} is now drunk"
  end
end
