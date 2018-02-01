FactoryGirl.define do
  factory :account, class: 'Account::Base' do

    transient do
      password Import.global('config.default_account_password')
    end

    person
    email { |account| person.email }
    status_id { Account::Status.find_or_create_by(name: 'Verified').id }

    after(:create) do |account, evaluator|
      password_hash = BCrypt::Password.create(evaluator.password)
      Account::PasswordHash.create(account: account, password_hash: password_hash)
    end
    trait :admin do
      after(:create) do |account|
        account.person.add_role(Role::BUZZN_OPERATOR)
      end
    end
  end
end
