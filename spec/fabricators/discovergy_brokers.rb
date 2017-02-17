# coding: utf-8
Fabricator :discovergy_broker, class_name: Broker::Discovergy do
  mode :in
  provider_login 'team@localpool.de'
  provider_password 'Zebulon_4711'
end

Fabricator :discovergy_broker_with_wrong_token, from: :discovergy_broker do
  provider_token_key "33559ae710df1f5b0e"
  provider_token_secret "33559ae710df1f5b0e"
end
