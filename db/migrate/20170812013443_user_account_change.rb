class UserAccountChange < ActiveRecord::Migration
  def change
    require_relative '../common_seeds'
    User.all.each do |user|
      account = Account::Base.create(email: user.email, person: user.person)
      
      Account::PasswordHash.create(account: account,
                                   password_hash: BCrypt::Password.create('Example123'))
    end
  end
end
