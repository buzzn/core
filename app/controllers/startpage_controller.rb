class StartpageController < ApplicationController

  layout 'startpage'


  def index
    if user_signed_in?
      redirect_to profile_path(current_user.profile)
    else
      redirect_to new_user_session_path
    end
  end


end
