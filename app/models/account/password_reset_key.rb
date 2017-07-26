module Account
  class PasswordResetKey < ActiveRecord::Base
    self.table_name = :account_password_reset_keys

    belongs_to :account, class_name: Account::Base, foreign_key: :id
  end
end
