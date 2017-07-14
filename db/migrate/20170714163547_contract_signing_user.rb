class ContractSigningUser < ActiveRecord::Migration
  def up
    add_column :contracts, :signing_user_ng, :string, null: true
    Contract::Base.reset_column_information
    Contract::Base.all.each do |contract|
      if contract.signing_user_id
        user = User.find(contract.signing_user_id)
        contract.update(signing_user_ng: user.name)
      end
    end
    rename_column :contracts, :signing_user_ng, :signing_user
    remove_column :contracts, :signing_user_id
  end
end
