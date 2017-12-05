class ContractSigningUser < ActiveRecord::Migration
  def up
    add_column :contracts, :signing_user, :string, null: true
  end
end
