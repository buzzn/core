FactoryGirl.define do
  factory :account, class: 'Account::Base' do

    transient do
      password 'Example123'
    end

    person
    email { |account| person.email }
    status_id { Account::Status.find_or_create_by(name: 'Verified').id }

    after(:create) do |account, evaluator|
      password_hash = BCrypt::Password.create(evaluator.password)
      Account::PasswordHash.create(account: account, password_hash: password_hash)
    end
  end
end
