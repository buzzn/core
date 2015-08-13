class UserSerializer < ApplicationSerializer

  attributes :id, :email, :profile_id

  def profile_id
    object.profile.id
  end

end
