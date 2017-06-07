class OrganizationLegacyRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    r.on :id do |id|
      organization = OrganizationResource.retrieve(current_user, id)

      r.get! do
        organization
      end

      r.get! 'address' do
        organization.address!
      end

      r.on 'bank-accounts' do
        shared[:bank_account_parent] = organization
        r.run BankAccountRoda
      end
    end
  end
end
