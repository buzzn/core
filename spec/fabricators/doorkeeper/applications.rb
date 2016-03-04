Fabricator :application, class_name: Doorkeeper::Application do
  name { sequence(:name) { |i| "Application #{i}"  } }
  redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
  scopes 'public write'
  owner { Fabricate(:admin) }
end
