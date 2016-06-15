Fabricator :access_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  scopes 'public'
end

Fabricator :admin_access_token, from: :access_token do
  resource_owner_id { Fabricate(:admin).id }
  scopes 'public admin'
end

Fabricator :access_token_with_friend, from: :access_token do
  resource_owner_id { Fabricate(:user_with_friend).id }
end

Fabricator :access_token_with_metering_point, from: :access_token do
  resource_owner_id { Fabricate(:user_with_metering_point).id }
end

Fabricator :access_token_with_friend_and_metering_point, from: :access_token do
  resource_owner_id { Fabricate(:user_with_friend_and_metering_point).id }
end
