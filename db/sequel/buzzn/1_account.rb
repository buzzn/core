# copied from rodauth README and removed unused tables and DB switches

Sequel.migration do
  up do
    extension :date_arithmetic

    run 'CREATE EXTENSION citext;'

    # Used by the account verification and close account features
    create_table(:account_statuses) do
      Integer :id, :primary_key=>true
      String :name, :null=>false, :unique=>true
    end
    from(:account_statuses).import([:id, :name], [[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']])

    db = self
    create_table(:accounts) do
      primary_key :id, :type=>:Bignum
      foreign_key :status_id, :account_statuses, :null=>false, :default=>1
      citext :email, :null=>false
      constraint :valid_email, :email=>/^[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+$/
      index :email, :unique=>true, :where=>{:status_id=>[1, 2]}
      foreign_key :person_id, :persons, null: false, type: :uuid
    end

    deadline_opts = proc do |days|
      {:null=>false, :default=>Sequel.date_add(Sequel::CURRENT_TIMESTAMP, :days=>days)}
    end

    # Used by the password reset feature
    create_table(:account_password_reset_keys) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String :key, :null=>false
      DateTime :deadline, deadline_opts[1]
    end

    # Used by the account verification feature
    create_table(:account_verification_keys) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String :key, :null=>false
      DateTime :requested_at, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
    end

    # Used by the verify login change feature
    create_table(:account_login_change_keys) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String :key, :null=>false
      String :login, :null=>false
      DateTime :deadline, deadline_opts[1]
    end

    # Used by the remember me feature
    create_table(:account_remember_keys) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      String :key, :null=>false
      DateTime :deadline, deadline_opts[14]
    end

    # Used by the password expiration feature
    create_table(:account_password_change_times) do
      foreign_key :id, :accounts, :primary_key=>true, :type=>:Bignum
      DateTime :changed_at, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
    end

    # NOTE the PG_USER is for codeship
    user = ENV['PG_USER'] || get{Sequel.lit('current_user')} + '_password'
    run "GRANT REFERENCES ON accounts TO #{user}" rescue raise("execute: createuser -U postgres #{user}")
  end

  down do
    drop_table(:account_session_keys,
               :account_password_change_times,
               :account_remember_keys,
               :account_login_change_keys,
               :account_verification_keys,
               :account_password_reset_keys,
               :accounts,
               :account_statuses)
  end
end

