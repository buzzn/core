Fabricator :application, class_name: Doorkeeper::Application do
  name { sequence(:name) { |i| "Application #{i}"  } }
  redirect_uri 'https://app.com/callback'
end
