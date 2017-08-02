require_relative '../admin_roda'
module Admin
  class BillingCycleRoda < BaseRoda
    plugin :shared_vars
    plugin :created_deleted

    include Import.args[:env,
                        'transaction.create_billing_cycle',
                        'transaction.update_billing_cycle']

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]

      r.post! do
        created do
          create_billing_cycle.call(r.params,
                                    resource: [localpool.method(:create_billing_cycle)])
        end
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
          update_billing_cycle.call(r.params, resource: [billing_cycle])
        end

        r.delete! do
          deleted do
            billing_cycle.delete
          end
        end

        r.on 'billings' do
          shared[:billing_cycle] = billing_cycle
          r.run BillingRoda
        end
      end
    end
  end
end
