class BillingRoda < BaseRoda
  plugin :shared_vars
  plugin :created_deleted

  include Import.args[:env,
                      'transaction.create_regular_billings',
                      'transaction.update_billing']

  route do |r|

    billing_cycle = shared[:billing_cycle]

    r.get! do
      billing_cycle.billings
    end

    r.post! 'regular' do
      created do
        create_regular_billings.call(r.params,
                                     resource: [billing_cycle.method(:create_regular_billings)])
      end
    end

    r.on :id do |id|
      billing = billing_cycle.billing(id)
      
      r.patch! do |id|
        update_billing.call(r.params, resource: [billing])
      end

      r.delete! do |id|
        deleted do
          billing.delete
        end
      end
    end
  end
end
