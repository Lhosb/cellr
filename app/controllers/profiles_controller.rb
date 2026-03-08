class ProfilesController < ApplicationController
  def show
    @user = current_user
    @cellars = Cellar.left_outer_joins(:cellar_memberships)
                     .where("cellars.owner_id = :user_id OR cellar_memberships.user_id = :user_id", user_id: current_user.id)
                     .includes(:owner)
                     .order(created_at: :desc)

    @pending_invitations = current_user.pending_invitations.includes(:cellar, :invited_by).order(created_at: :desc)
    @editing = params[:edit].present?
  end

  def update
    @user = current_user

    ActiveRecord::Base.transaction do
      if requires_current_password?(profile_params)
        unless @user.valid_password?(profile_params[:current_password].to_s)
          @user.errors.add(:current_password, "is incorrect")
          raise ActiveRecord::RecordInvalid.new(@user)
        end
      end

      update_attrs = profile_params.except(:current_password)

      # Remove blank password params so Devise doesn't treat them as attempted updates
      if update_attrs[:password].blank?
        update_attrs.delete(:password)
        update_attrs.delete(:password_confirmation)
      end
      @user.update!(update_attrs)

      case params[:drinking_status]
      when "start"
        DrinkingSessions::Start.call(user: @user)
      when "stop"
        DrinkingSessions::Stop.call(user: @user)
      end
    end

    redirect_to profile_path, notice: "Profile updated"
  rescue ActiveRecord::RecordInvalid
    @user = current_user
    render :show, status: :unprocessable_entity
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end

  def requires_current_password?(attrs)
    return true if attrs[:password].present?
    return false unless attrs[:email].present?
    attrs[:email].to_s.downcase != current_user.email.to_s.downcase
  end
end
