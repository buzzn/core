class ChangeContractContractingPartyRelation < ActiveRecord::Migration
  def change
    remove_reference :contracts, :customer
    remove_reference :contracts, :contractor
    add_belongs_to :contracts, :customer, references: :contracting_parties, index: true, type: :uuid, polymorphic: true
    add_belongs_to :contracts, :contractor, references: :contracting_parties, index: true, type: :uuid, polymorphic: true
  end
end
