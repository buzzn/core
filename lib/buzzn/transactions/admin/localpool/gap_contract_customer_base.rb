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

  def unassign_and_delete_gap_contract_customer(resource:, **)
    gap_contract_customer = resource.object.gap_contract_customer
    if gap_contract_customer.class.name == 'Organization::General'
      gap_contract_customer_contact = gap_contract_customer.contact
      gap_contract_customer_legal_representation = gap_contract_customer.legal_representation
    else
      gap_contract_customer_contact = nil
      gap_contract_customer_legal_representation = nil
    end
    #because of foreign_key constraints the gap contract customer must be unassigned from the gap contract before it can be deleted
    resource.object.gap_contract_customer = nil
    resource.object.save!
    gap_contract_customer.delete
    #in case the gap contract customer is an organisation, 
    #the gap_contract customer contact and the gap contract customer legal representation 
    #can only be deleted after the contact has been deleted, due to foreign_key_constraints
    unless gap_contract_customer_contact.nil? || gap_contract_customer_legal_representation.nil?
      gap_contract_customer_contact.delete
      gap_contract_customer_legal_representation.delete
    end
    resource.object
  end

end
