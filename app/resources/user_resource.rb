class UserResource < ApplicationResource

  attributes :id, :email, :profile_id

  def profile_id
    @model.profile.id
  end

end
