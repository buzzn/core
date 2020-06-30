# copied from rodauth README and removed unused tables and DB switches

Sequel.migration do
  up do
    extension :date_arithmetic
    deadline_opts = proc do |days|
      if database_type == :mysql
        {:null=>false}
      else
        {:null=>false, :default=>Sequel.date_add(Sequel::CURRENT_TIMESTAMP, :days=>days)}
      end
    end

    # Used by the jwt refresh feature
    create_table(:account_jwt_refresh_keys) do
      primary_key :id, :type=>:Bignum
      foreign_key :account_id, :accounts, :null=>false, :type=>:Bignum
      String :key, :null=>false
      DateTime :deadline, deadline_opts[1]
      index :account_id, :name=>:account_jwt_rk_account_id_idx
    end
  end
  down do
    drop_table(:account_jwt_refresh_keys)
  end
end
