# encoding: utf-8

Fabricator :user do
  email             { Faker::Internet.email }
  password          'testtest'
  profile           { Fabricate(:profile) }
  after_create { |user | user.confirm! }
end


Fabricator :felix, from: :user do
  email               'felix@buzzn.net'
  profile             { Fabricate(:profile_felix) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :justus, from: :user do
  email       'justus@buzzn.net'
  profile     { Fabricate(:profile_justus) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :danusch, from: :user do
  email       'danusch@buzzn.net'
  profile     { Fabricate(:profile_danusch) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :thomas, from: :user do
  email       'thomas@buzzn.net'
  profile     { Fabricate(:profile_thomas) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :martina, from: :user do
  email       'martina@buzzn.net'
  profile     { Fabricate(:profile_martina) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :stefan, from: :user do
  email       'stefan@buzzn.net'
  profile     { Fabricate(:profile_stefan) }
  contracting_party   { Fabricate(:contracting_party) }
end
Fabricator :karin, from: :user do
  email       'karin.smith@solfux.de'
  profile     { Fabricate(:profile_karin) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :ole, from: :user do
  email       'ole@buzzn.net'
  profile     { Fabricate(:profile_ole) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :philipp, from: :user do
  email       'philipp@buzzn.net'
  profile     { Fabricate(:profile_philipp) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :christian, from: :user do
  email       'christian@buzzn.net'
  profile     { Fabricate(:profile_christian) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :jan_gerdes, from: :user do
  email     'jangerdes@stiftung-fuer-tierschutz.de'
  profile   { Fabricate(:profile_jangerdes) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :christian_schuetze, from: :user do
  email     'christian@schuetze.de'
  profile   { Fabricate(:profile_christian_schuetze) }
  contracting_party   { Fabricate(:contracting_party) }
end





