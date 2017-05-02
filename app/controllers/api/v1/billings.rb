module API
  module V1
    class Billings < Grape::API
      include API::V1::Defaults
      resource 'billings' do

        desc "Update a Billing"
        params do
          requires :id, type: String, desc: "Billing ID"
          optional :receivables_cents, type: Integer, desc: "The money, the LSN has to pay or get from the LSG."
          optional :invoice_number, type: String, desc: "The Invoice Number for the Billing"
          optional :status, type: String, values: Billing.all_stati.map(&:to_s), desc: "The current status of the Billing"
        end
        patch ':id' do
          BillingResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end
      end
    end
  end
end