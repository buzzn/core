require_relative '../localpool'

class Transactions::Admin::Localpool::GapContractCustomerBase < Transactions::Base

  def assign_gap_contract_customer(new_customer:, resource:, **)
    resource.object.gap_contract_customer = new_customer&.object
    if new_customer != resource.object.gap_contract_customer
      resource.object.gap_contract_customer_bank_account = nil
    end
    resource.object.save!
    resource.gap_contract_customer
  end

end
