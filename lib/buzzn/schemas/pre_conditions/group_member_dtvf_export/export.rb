require_relative '../group_member_dtvf_export'

Schemas::PreConditions::GroupMemberDtvfExport::Export = Schemas::Support.Schema do

  configure do
    def contracts_have_contact?(contracts)
      contracts.select { |x| x.contact.nil? }.empty?
    end
  end

  required(:contracts).filled

  rule(contracts: [:contracts]) do |contracts|
    contracts.contracts_have_contact?
  end

end
