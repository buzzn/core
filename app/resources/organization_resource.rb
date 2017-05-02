class OrganizationSingleResource < Buzzn::EntityResource

  model Organization

  attributes  :name,
              :phone,
              :fax,
              :website,
              :email,
              :description,
              :mode

  attributes :updatable, :deletable

  has_one :address

  # API methods for endpoints

  def members
    object.members.readable_by(@current_user)
  end

  def managers
    object.managers.readable_by(@current_user)
  end

  def bank_accounts
    object.bank_accounts.readable_by(@current_user).collect { |ba| BankAccountResource.new(ba) }
  end

end

class ContractingPartyOrganizationSingleResource < OrganizationSingleResource

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number
end

class OrganizationCollectionResource < OrganizationSingleResource
end

# to satisfy rails auto load
OrganizationResource = OrganizationSingleResource
