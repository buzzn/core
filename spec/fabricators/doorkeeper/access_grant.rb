Fabricator :access_grant, class_name: Doorkeeper::AccessGrant do
  application_id { Fabricate(:application).id }
  resource_owner_id { Fabricate(:user).id }
  redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
  expires_in 100
  scopes 'public'
end
