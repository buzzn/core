shared_context :database_integrity do
  after(:each, database_integrity: true) do
    ActiveRecord::Base.connection.rollback_db_transaction
  end
end

# https://github.com/DatabaseCleaner/database_cleaner/issues/173#issuecomment-16440112
