Fabricator :public_access_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  scopes 'public'
end

Fabricator :smartmeter_access_token_no_role, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  scopes 'smartmeter'
end

Fabricator :manager_access_token_no_role, from: :access_token do
  resource_owner_id { Fabricate(:user).id }
  scopes 'public manager'
end

Fabricator :manager_access_token_as_admin, from: :access_token do
  resource_owner_id { Fabricate(:admin).id }
  scopes 'public manager'
end

Fabricator :access_token_received_friendship_request, from: :access_token do
  resource_owner_id { Fabricate(:user_received_friendship_request).id }
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
