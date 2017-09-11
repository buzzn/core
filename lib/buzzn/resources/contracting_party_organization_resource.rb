require_relative 'organization_resource'
class ContractingPartyOrganizationResource < OrganizationResource

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number,
              :updatable, :deletable

end
