module Account
  class LoginChangeKey < ActiveRecord::Base
    self.table_name = :account_login_change_keys

    belongs_to :account, class_name: Account::Base, foreign_key: :id
  end
end
