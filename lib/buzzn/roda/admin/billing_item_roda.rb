require_relative '../admin_roda'

class Admin::BillingItemRoda < BaseRoda

  plugin :shared_vars
  include Import.args[:env,
                      update:'transactions.admin.billing_item.update',
                      calculate: 'transactions.admin.billing_item.calculate',
                      ]

  route do |r|
    billing_items = shared[:billing_items]

    r.on :id do |id|
      item = billing_items.retrieve(id)

      r.patch! do
        update.(resource: item, params: r.params)
      end

      r.on 'calculate' do
        r.patch! do
          calculate.(resource: item, params: r.params)
        end
      end

      r.others!
    end
  end

end
