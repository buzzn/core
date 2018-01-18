require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/contract/payment'

class CreatePayment < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Contract::Payment)

  def up
    SCHEMA.up(:payments, self)
    add_belongs_to :payments, :contract, null: false, index: true, type: :uuid
    add_foreign_key :payments, :contracts, name: :fk_payments_contract, null: false, on_delete: :cascade
  end

  def down
    remove_reference :payments, :contract
    remove_foreign_key :payments, :contracts, name: :fk_payments_contract
    SCHEMA.down(:payments, self)
  end
end
