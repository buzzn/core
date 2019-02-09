class Transactions::Admin::Localpool::GapContractCustomerBase < Transactions::Base

  def assign_gap_contract_customer(new_customer:, resource:, **)
    resource.object.gap_contract_customer = new_customer&.object
    resource.object.save!
    resource.gap_contract_customer
  end

end
