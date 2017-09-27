# encoding: utf-8

Fabricator :user, class_name: Account::Base do
  i = 0
  email             { "user.#{i+=1}@buzzn.net" }
  person            { Fabricate(:person) }
  after_create { |account|
    Account::PasswordHash.create(account: account,
                                 password_hash: BCrypt::Password.create('Example123'))
    account.person.add_role(Role::SELF, account.person)
    account.person.update(email: account.email)
  }
end

Fabricator :admin, from: :user do
  after_create { |account| account.person.add_role(Role::BUZZN_OPERATOR) }
end

Fabricator :buzzn_operator, from: :user do
  after_create { |account| account.person.add_role(Role::BUZZN_OPERATOR) }
end

Fabricator :buzzn_operator, from: :user do
  after_create { |account| account.person.add_role(:buzzn_operator) }
end

Fabricator :felix, from: :admin do
  email               'felix@buzzn.net'
  person             { Fabricate(:person_felix) }
end

Fabricator :ralf, from: :admin do
  email               'ralf@buzzn.net'
  person             { Fabricate(:person_ralf) }
end

Fabricator :justus, from: :admin do
  email       'justus@buzzn.net'
  person     { Fabricate(:person_justus) }
end

Fabricator :danusch, from: :admin do
  email       'danusch@buzzn.net'
  person     { Fabricate(:person_danusch) }
end

Fabricator :thomas, from: :admin do
  email       'thomas@buzzn.net'
  person     { Fabricate(:person_thomas) }
end

Fabricator :eva, from: :admin do
  email       'eva@buzzn.net'
  person     { Fabricate(:person_eva) }
end

Fabricator :stefan, from: :admin do
  email       'stefan@buzzn.net'
  person     { Fabricate(:person_stefan) }
end
Fabricator :karin, from: :admin do
  email       'karin.smith@solfux.de'
  person     { Fabricate(:person_karin) }
end

Fabricator :pavel, from: :admin do
  email       'pavel@buzzn.net'
  person     { Fabricate(:person_pavel) }
end

Fabricator :philipp, from: :admin do
  email       'philipp@buzzn.net'
  person     { Fabricate(:person_philipp) }
end

Fabricator :christian, from: :user do
  email       'christian@buzzn.net'
  person     { Fabricate(:person_christian) }
end

Fabricator :jan_gerdes, from: :user do
  email     'jangerdes@stiftung-fuer-tierschutz.de'
  person   { Fabricate(:person_jangerdes) }
end

Fabricator :christian_schuetze, from: :admin do
  email     'christian@schuetze.de'
  person   { Fabricate(:person_christian_schuetze) }
end

Fabricator :mustafa, from: :user do
  email       'mustafaakman@ymail.de'
  person     { Fabricate(:person_mustafa) }
end

Fabricator :kristian, from: :admin do
  email       'm.kristian@web.de'
  person     { Fabricate(:person_kristian) }
end


Fabricator :uxtest_user, from: :user do
  email               'ux-test@buzzn.net'
  person             { Fabricate(:person_uxtest) }
end










#Ab hier: Hell & Warm (Forstenried)
Fabricator :mabe, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_5, addition: 'S 43')) }
end

Fabricator :inbr, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_5, addition: 'M 21')) }
end

Fabricator :pebr, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_5, addition: 'M 25')) }
end

Fabricator :anbr, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_7, addition: 'S 25')) }
end

Fabricator :gubr, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_5, addition: 'M 14')) }
end

Fabricator :mabr, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_7, addition: 'S 42')) }
end

Fabricator :dabr, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_7, addition: 'S 22')) }
end

Fabricator :zubu, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_7, addition: 'S 41')) }
end

Fabricator :mace, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_5, addition: 'M 32')) }
end

Fabricator :stcs, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_5, addition: 'M 13')) }
end

Fabricator :pafi, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_7, addition: 'S 33')) }
end

Fabricator :raja, from: :user do
  after_create { |u| u.person.update(address: Fabricate(:address_limmat_7, addition: 'S 33')) }
end

Fabricator :pesc, from: :user do
end
