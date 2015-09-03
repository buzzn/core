class Users::InvitationsController < Devise::InvitationsController

  # def update
  #   if this
  #     redirect_to root_path
  #   else
  #     super
  #   end
  # end




  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      # Only add some parameters
      devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name, :phone]
      # Override accepted parameters
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit( :first_name,
                  :last_name,
                  :phone,
                  :password,
                  :password_confirmation,
                  :invitation_token,
                  profile_attributes: [:id, :first_name, :last_name, :terms]
                  )
      end
    end


end


