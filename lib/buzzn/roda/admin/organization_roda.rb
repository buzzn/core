require_relative '../admin_roda'
class Admin::OrganizationRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    organizations = shared[:localpool].organizations

    r.on :id do |id|
      organization = organizations.retrieve(id)

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
