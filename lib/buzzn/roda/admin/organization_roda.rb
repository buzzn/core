require_relative '../admin_roda'
require_relative 'bank_account_roda'
module Admin
  class OrganizationRoda < BaseRoda
    plugin :shared_vars

    route do |r|

      organizations = shared[LocalpoolRoda::PARENT].organizations

      r.get! do
        organizations
      end

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
end
