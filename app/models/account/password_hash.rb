module Account
  class PasswordHash < ActiveRecord::Base
    self.table_name = :account_password_hashes

    belongs_to :account, class_name: Account::Base, foreign_key: :id
  end
end
