class UserAccountChange < ActiveRecord::Migration
  def change
    require_relative '../seeds/setup_data_common'
    User.all.each do |user|
      next unless user.person
      account = Account::Base.create(email: user.email, person: user.person)

      Account::PasswordHash.create(account: account,
                                   password_hash: BCrypt::Password.create('Example123'))
    end
  end
end
