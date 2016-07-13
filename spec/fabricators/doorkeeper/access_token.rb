Fabricator :public_access_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  scopes 'public'
end

Fabricator :smartmeter_access_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  scopes 'smartmeter'
end

Fabricator :full_access_token, from: :public_access_token do
  resource_owner_id { Fabricate(:user).id }
  scopes 'full'
end

Fabricator :full_access_token_as_admin, from: :public_access_token do
  resource_owner_id { Fabricate(:admin).id }
  scopes 'public full'
end

Fabricator :access_token_received_friendship_request, from: :public_access_token do
  resource_owner_id { Fabricate(:user_received_friendship_request).id }
end

Fabricator :access_token_with_friend, from: :public_access_token do
  resource_owner_id { Fabricate(:user_with_friend).id }
end

Fabricator :access_token_with_metering_point, from: :public_access_token do
  resource_owner_id { Fabricate(:user_with_metering_point).id }
end

Fabricator :access_token_with_friend_and_metering_point, from: :public_access_token do
  resource_owner_id { Fabricate(:user_with_friend_and_metering_point).id }
end
