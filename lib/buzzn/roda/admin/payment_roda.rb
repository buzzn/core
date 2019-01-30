require_relative '../admin_roda'

class Admin::PaymentRoda < BaseRoda

  include Import.args[:env,
                      'transactions.admin.contract.base.payment.create',
                      'transactions.admin.contract.base.payment.update',
                      'transactions.admin.contract.base.payment.delete',
                     ]

  plugin :shared_vars

  route do |r|

    payments = shared[:payments]

    r.get! do
      payments
    end

    r.post! do
      create.(resource: payments, params: r.params)
    end

    r.on :id do |id|
      payment = payments.retrieve(id)

      r.get! do
        payment
      end

      r.patch! do
        update.(resource: payment, params: r.params)
      end

      r.delete! do
        delete.(resource: payment)
      end
    end
  end

end
