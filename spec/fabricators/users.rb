# encoding: utf-8

Fabricator :user do
  i = 0
  email             { "user#{i+=1}@gmail.de" }
  password          '12345678'
  profile           { Fabricate(:profile) }
  created_at        { (rand*10).days.ago }
  bank_account      { Fabricate(:bank_account) }
  after_create { |user|
    user.confirm
  }
end


['input_register', 'output_register'].each do |register|
  Fabricator "user_with_friend_and_#{register}", from: :user do
    after_create { |user |
      friend = Fabricate("user_with_#{register}")
      user.friendships.create(friend: friend)
      friend.friendships.create(friend: user)
    }
  end

  Fabricator "user_with_#{register}", from: :user do
    after_create { |user|
      user.add_role(:manager, Fabricate(register, meter: Fabricate(:meter)))
    }
  end
end

Fabricator :admin, from: :user do
  after_create { |user| user.add_role(:admin) }
end

Fabricator :user_received_friendship_request, from: :user do
  after_create do |user|
    user2 = Fabricate(:user)
    Fabricate(:friendship_request, { sender: user2, receiver: user })
  end
end

Fabricator :user_with_friend, from: :user do
  after_create { |user |
    friend = Fabricate(:user)
    user.friendships.create(friend: friend)
    friend.friendships.create(friend: user)
  }
end

Fabricator :felix, from: :user do
  email               'felix@buzzn.net'
  profile             { Fabricate(:profile_felix) }
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

Fabricator :eva, from: :user do
  email       'eva@buzzn.net'
  profile     { Fabricate(:profile_eva) }
end

Fabricator :stefan, from: :user do
  email       'stefan@buzzn.net'
  profile     { Fabricate(:profile_stefan) }
end
Fabricator :karin, from: :user do
  email       'karin.smith@solfux.de'
  profile     { Fabricate(:profile_karin) }
end

Fabricator :pavel, from: :user do
  email       'pavel@buzzn.net'
  profile     { Fabricate(:profile_pavel) }
end

Fabricator :philipp, from: :user do
  email       'philipp@buzzn.net'
  profile     { Fabricate(:profile_philipp) }
end

Fabricator :christian, from: :user do
  email       'christian@buzzn.net'
  profile     { Fabricate(:profile_christian) }
end

Fabricator :jan_gerdes, from: :user do
  email     'jangerdes@stiftung-fuer-tierschutz.de'
  profile   { Fabricate(:profile_jangerdes) }
end

Fabricator :christian_schuetze, from: :user do
  email     'christian@schuetze.de'
  profile   { Fabricate(:profile_christian_schuetze) }
end

Fabricator :geloeschter_benutzer, from: :user do
  email     'sys@buzzn.net'
  profile   { Fabricate(:profile_geloeschter_benutzer) }
end

Fabricator :mustafa, from: :user do
  email       'mustafaakman@ymail.de'
  profile     { Fabricate(:profile_mustafa) }
end

Fabricator :kristian, from: :user do
  email       'm.kristian@web.de'
  profile     { Fabricate(:profile_kristian) }
end


Fabricator :uxtest_user, from: :user do
  email               'ux-test@buzzn.net'
  profile             { Fabricate(:profile_uxtest) }
end










#Ab hier: Hell & Warm (Forstenried)
Fabricator :mabe, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 43')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Ma Be') }
end

Fabricator :inbr, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 21')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'In Br') }
end

Fabricator :pebr, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 25')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Pe Br') }
end

Fabricator :anbr, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 25')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'An Br') }
end

Fabricator :gubr, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 14')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Gu Br') }
end

Fabricator :mabr, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 42')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Ma Br') }
end

Fabricator :dabr, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 22')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Da Br') }
end

Fabricator :zubu, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 41')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Zu Bu') }
end

Fabricator :mace, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 32')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Ma Ce') }
end

Fabricator :stcs, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 13')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'St Cs') }
end

Fabricator :pafi, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 33')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Pa Fi') }
end

Fabricator :raja, from: :user do
  profile             { Fabricate(:profile) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 33')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Ra Ja') }
end



Fabricator :pesc, from: :user do
  profile             { Fabricate(:profile) }
end
