Fabricator :application, class_name: Doorkeeper::Application do
  name { sequence(:name) { |i| "Application #{i}"  } }
  redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
  scopes 'simple write'
  owner { Fabricate(:admin) }
end
