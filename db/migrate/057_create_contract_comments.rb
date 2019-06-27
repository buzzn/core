class CreateContractComments < ActiveRecord::Migration

  def up
    create_table :comments_contracts, id: false do |t|
      t.integer :contract_id, null: false
      t.integer :comment_id, null: false
      t.index [:contract_id, :comment_id], unique: true
    end

    add_foreign_key :comments_contracts, :comments, name:  :fk_comments_contracts_comment
    add_foreign_key :comments_contracts, :contracts, name: :fk_comments_contracts_contract
  end

end
