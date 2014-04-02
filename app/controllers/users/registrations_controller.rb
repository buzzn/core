class Users::RegistrationsController < Devise::RegistrationsController
 
  before_filter :configure_permitted_parameters
 
  protected
 
  def configure_permitted_parameters


    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit( :image, 
                :first_name, 
                :last_name,  
                :gender, 
                :phone,
                :newsletter_notifications, 
                :meter_notifications, 
                :group_notifications,
                :email, 
                :password, 
                :password_confirmation, 
                :current_password,
                bank_accounts_attributes: [:id, :holder, :iban, :bic, :_destroy]
              )
    end

  end
 
end