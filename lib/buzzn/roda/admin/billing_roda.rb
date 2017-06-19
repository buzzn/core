require_relative '../admin_roda'
class Admin::BillingRoda < BaseRoda
  plugin :shared_vars
  plugin :created_deleted

  include Import.args[:env,
                      'transaction.create_regular_billings',
                      'transaction.update_billing']

  route do |r|

    billing_cycle = shared[:billing_cycle]

    r.post! 'regular' do
      created do
        create_regular_billings.call(r.params,
                                     resource: [billing_cycle.method(:create_regular_billings)])
      end
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
        update_billing.call(r.params, resource: [billing])
      end

      r.delete! do
        deleted do
          billing.delete
        end
      end
    end
  end
end
