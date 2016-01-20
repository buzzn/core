Fabricator :access_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
end

Fabricator :admin_access_token, from: :access_token do
  resource_owner_id { Fabricate(:admin).id }
end
