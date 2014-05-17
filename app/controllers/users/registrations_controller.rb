class Users::RegistrationsController < Devise::RegistrationsController

  before_filter :configure_permitted_parameters



  def update
    @user = User.find(current_user.id)

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

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] || params[:user][:password].present?
  end




  protected

  def configure_permitted_parameters

    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(
                :email,
                :password,
                :password_confirmation,
                :current_password,
                :terms,
                profile_attributes: [:id, :image, :first_name, :last_name, :gender, :phone, :newsletter_notifications, :meter_notifications, :group_notifications, :_destroy]
              )
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(
                :email,
                :password,
                :password_confirmation,
                :current_password,
                :terms,
                profile_attributes: [:id, :image, :first_name, :last_name, :gender, :phone, :newsletter_notifications, :meter_notifications, :group_notifications, :_destroy]
              )
    end

  end

end