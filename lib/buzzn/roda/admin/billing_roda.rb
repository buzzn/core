require_relative '../admin_roda'

class Admin::BillingRoda < BaseRoda

  include Import.args[:env,
                      'transactions.admin.billing.create',
                      'transactions.admin.billing.update',
                      'transactions.admin.billing.delete',
                     ]

  plugin :shared_vars

  route do |r|

    billings = shared[:billings]
    parent = shared[:parent]

    r.get! do
      billings
    end

    r.post! do
      create.(resource: billings, params: r.params, parent: parent)
    end

    r.on :id do |id|
      billing = billings.retrieve(id)

      r.get! do
        billing
      end

      r.patch! do
        update.(resource: billing, params: r.params)
      end

      r.delete! do
        delete.(resource: billing)
      end

      r.on 'items' do
        shared[:billing_items] = billing.items
        r.run Admin::BillingItemRoda
      end

    end
  end

end
