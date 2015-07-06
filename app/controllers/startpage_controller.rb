class StartpageController < ApplicationController

  layout 'startpage'


  def index
    if user_signed_in?
      redirect_to current_user_profile_path
    else
      redirect_to new_user_session_path
    end
  end


end
