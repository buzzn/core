class Users::RegistrationsController < Devise::RegistrationsController

  before_filter :configure_permitted_parameters



  def update
    @user = User.find(current_user.id)

    if params[:cancel].present?
      redirect_to profile_path(@user.profile)
    else
      successfully_updated = if needs_password?(@user, params)
        @user.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
      else
        # remove the virtual current_password attribute
        # update_without_password doesn't know how to ignore it
        params[:user].delete(:current_password)
        @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
      end

      if successfully_updated
        set_flash_message :notice, :updated
        # Sign in the user bypassing validation in case his password changed
        sign_in @user, :bypass => true
        redirect_to after_update_path_for(@user)
      else
        render "edit"
      end
    end
  end

  private

    # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?(user, params)
      user.email != params[:user][:email] || params[:user][:password].present?
    end


    def after_inactive_sign_up_path_for(resource)
      new_user_session_path
    end


  protected

    def after_sign_up_path_for(resource)
      signed_in_root_path(resource)
    end

    def after_update_path_for(resource)
      signed_in_root_path(resource)
    end

    def configure_permitted_parameters

      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(
                  :email,
                  :password,
                  :password_confirmation,
                  profile_attributes: [:id, :first_name, :last_name, :terms]
                )
      end

      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(
                  :email,
                  :password,
                  :password_confirmation,
                  :current_password,
                  profile_attributes: [:id, :username, :image, :user_name, :first_name, :last_name, :gender, :phone, :terms, :newsletter_notifications, :location_notifications, :group_notifications, :_destroy, :description]
                )
      end

    end

end