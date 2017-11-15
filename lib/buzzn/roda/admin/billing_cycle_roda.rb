require_relative '../admin_roda'
require_relative '../../transactions/admin/billing_cycle/create'
require_relative '../../transactions/admin/billing_cycle/update'
require_relative '../../transactions/admin/billing_cycle/delete'

module Admin
  class BillingCycleRoda < BaseRoda
    plugin :shared_vars

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]

      r.post! do
        Transactions::Admin::BillingCycle::Create
          .for(localpool)
          .call(r.params)
      end

      billing_cycles = localpool.billing_cycles
      r.get! do
        billing_cycles
      end

      r.on :id do |id|
        billing_cycle = billing_cycles.retrieve(id)

        r.get! do
          billing_cycle
        end

        r.patch! do
          Transactions::Admin::BillingCycle::Update
            .for(billing_cycle)
            .call(r.params)
        end

        r.delete! do
          Transactions::Admin::BillingCycle::Delete
            .call(billing_cycle)
        end

        r.on 'billings' do
          shared[:billing_cycle] = billing_cycle
          r.run BillingRoda
        end
      end
    end
  end
end
