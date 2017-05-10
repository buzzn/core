class OrganizationRoda < BaseRoda

  route do |r|

    r.on :id do |id|
      organization = OrganizationResource.retrieve(current_user, id)

      r.get! do
        organization
      end

      r.get! 'address' do
        organization.address!
      end

      r.get! 'bank-accounts' do
        organization.bank_accounts
      end
    end
  end
end
