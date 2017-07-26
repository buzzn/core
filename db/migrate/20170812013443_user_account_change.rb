class UserAccountChange < ActiveRecord::Migration
  def change
    User.all.each do |user|
      account = Account::Base.create(eamil: user.email, person: user.person)
      
      Account::PasswordHash.create(account: account,
                                   password_hash: BCrypt::Password.create('Example123'))
    end
  end
end
