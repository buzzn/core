require_relative '../admin_roda'
require_relative '../../transactions/admin/billing/create_regular'
require_relative '../../transactions/admin/billing/update'
require_relative '../../transactions/admin/billing/delete'

class Admin::BillingRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    billing_cycle = shared[:billing_cycle]

    r.post! 'regular' do
      Transactions::Admin::Billing::CreateRegular
          .for(billing_cycle)
          .call(r.params)
    end

    billings = billing_cycle.billings
    r.get! do
      billings
    end

    r.on :id do |id|
      billing = billings.retrieve(id)

      r.get! do
        billing
      end

      r.patch! do
        Transactions::Admin::Billing::Update
          .for(billing)
          .call(r.params)
      end

      r.delete! do
        Transactions::Admin::Billing::Delete
          .call(billing)
      end
    end
  end
end
