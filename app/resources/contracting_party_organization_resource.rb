class ContractingPartyOrganizationResource < OrganizationResource
  include BankAccountResource::Create

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number
end
