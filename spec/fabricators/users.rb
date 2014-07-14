# encoding: utf-8

Fabricator :user do
  email             { Faker::Internet.email }
  password          'testtest'
  profile           { Fabricate(:profile) }
  after_create { |user | user.confirm! }
end

Fabricator :admin, from: :user do
  email       'admin@buzzn.net'
end

Fabricator :felix, from: :user do
  email       'felix@buzzn.net'
  profile     { Fabricate(:profile_felix) }
end

Fabricator :justus, from: :user do
  email       'justus@buzzn.net'
  profile     { Fabricate(:profile_justus) }
end

Fabricator :danusch, from: :user do
  email       'danusch@buzzn.net'
  profile     { Fabricate(:profile_danusch) }
end

Fabricator :thomas, from: :user do
  email       'thomas@buzzn.net'
  profile     { Fabricate(:profile_thomas) }
end

Fabricator :martina, from: :user do
  email       'martina@buzzn.net'
  profile     { Fabricate(:profile_martina) }
end

Fabricator :stefan, from: :user do
  email       'stefan@buzzn.net'
  profile     { Fabricate(:profile_stefan) }
end
Fabricator :karin, from: :user do
  email       'karin.smith@solfux.de'
  profile     { Fabricate(:profile_karin) }
end

Fabricator :ole, from: :user do
  email       'ole@buzzn.net'
  profile     { Fabricate(:profile_ole) }
end

Fabricator :philipp, from: :user do
  email       'philipp@buzzn.net'
  profile     { Fabricate(:profile_philipp) }
end

Fabricator :christian, from: :user do
  email       'christian@buzzn.net'
  profile     { Fabricate(:profile_christian) }
end

