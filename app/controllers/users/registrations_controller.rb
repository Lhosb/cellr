module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      existing_user = User.find_by(email: normalized_email)

      if existing_user&.invited?
        activate_invited_user(existing_user)
        return
      end

      if request.format.json?
        create_via_json
        return
      end

      super
    end

    private

    def normalized_email
      sign_up_params[:email]&.strip&.downcase
    end

    # Activate a passwordless user that was pre-created through an invitation.
    # Sets their password and signs them in.
    def activate_invited_user(user)
      user.password = sign_up_params[:password]
      user.password_confirmation = sign_up_params[:password_confirmation]

      if user.save
        sign_in(user)
        respond_to do |format|
          format.html { redirect_to after_sign_up_path_for(user) }
          format.json { render json: { user: { id: user.id, email: user.email } }, status: :ok }
        end
      else
        respond_to do |format|
          format.html do
            self.resource = user
            clean_up_passwords(user)
            set_minimum_password_length
            render :new, status: :unprocessable_entity
          end
          format.json { render json: { errors: user.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def create_via_json
      build_resource(sign_up_params)
      if resource.save
        sign_up(resource_name, resource)
        render json: { user: { id: resource.id, email: resource.email } }, status: :created
      else
        clean_up_passwords resource
        set_minimum_password_length
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
