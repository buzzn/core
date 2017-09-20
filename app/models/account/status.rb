module Account
  class Status < ActiveRecord::Base
    self.table_name = :account_statuses
  end
end
