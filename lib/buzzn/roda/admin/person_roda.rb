require_relative '../admin_roda'
require_relative 'bank_account_roda'
module Admin
  class PersonRoda < BaseRoda
    plugin :shared_vars

    route do |r|

      persons = shared[LocalpoolRoda::PARENT].persons

      r.get! do
        persons.filter(r.params['filter'])
      end

      r.on :id do |id|
        person = persons.retrieve(id)

        r.get! do
          person
        end

        r.on 'bank-accounts' do |id|
          shared[:bank_account_parent] = person
          r.run BankAccountRoda
        end
      end
    end
  end
end
