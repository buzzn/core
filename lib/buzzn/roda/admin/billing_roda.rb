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
    parent_contract = shared[:parent_contract]

    r.get! do
      billings
    end

    r.post! do
      create.(resource: billings, params: r.params, contract: parent_contract)
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

      r.on 'documents' do
        shared[:documents] = billing.documents
        shared[:with_post] = false
        r.run Admin::DocumentRoda
      end

    end
  end

end
