Fabricator :simple_access_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  scopes 'simple'
end

Fabricator :smartmeter_access_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  scopes 'smartmeter'
end

Fabricator :full_access_token, from: :simple_access_token do
  resource_owner_id { Fabricate(:user).id }
  scopes 'full'
end

Fabricator :full_access_token_as_admin, from: :simple_access_token do
  resource_owner_id { Fabricate(:admin).id }
  scopes 'simple full'
end

Fabricator :access_token_received_friendship_request, from: :simple_access_token do
  resource_owner_id { Fabricate(:user_received_friendship_request).id }
end

Fabricator :access_token_with_friend, from: :simple_access_token do
  resource_owner_id { Fabricate(:user_with_friend).id }
end

Fabricator :access_token_with_metering_point, from: :simple_access_token do
  resource_owner_id { Fabricate(:user_with_metering_point).id }
end

Fabricator :access_token_with_friend_and_metering_point, from: :simple_access_token do
  resource_owner_id { Fabricate(:user_with_friend_and_metering_point).id }
end
