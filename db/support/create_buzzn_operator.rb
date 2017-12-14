def create_buzzn_operator(first_name:, last_name:, email:, password:)
  person  = Person.create(first_name: first_name, last_name: last_name, email: email)
  account = Account::Base.create(email: person.email,
                                 status_id: Account::Status.find_by(name: 'Verified').id,
                                 person: person)
  account.person.add_role(Role::SELF, person)
  account.person.add_role(Role::BUZZN_OPERATOR)
  password_hash = BCrypt::Password.create(password)
  Account::PasswordHash.create(account: account, password_hash: password_hash)
end
