class AccessTokensController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def index
    @access_tokens = Doorkeeper::AccessToken.where(
                          expires_in: nil,
                          resource_owner_id: current_user.id
                          )
  end


end
