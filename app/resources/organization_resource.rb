class OrganizationResource < Buzzn::EntityResource

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

  has_many :bank_accounts

end

class ContractingPartyOrganizationResource < OrganizationResource
  include BankAccountResource::Create

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number
end
