Fabricator :user_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
end

Fabricator :admin_token, class_name: Doorkeeper::AccessToken do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:admin).id }
end
