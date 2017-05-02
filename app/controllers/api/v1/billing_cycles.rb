module API
  module V1
    class BillingCycles < Grape::API
      include API::V1::Defaults
      resource 'billing-cycles' do

        desc "Update a Billing Cycle."
        params do
          requires :id, type: String, desc: "Billing Cycle ID"
          optional :name, type: String, desc: "Name of the Billing Cycle"
          optional :begin_date, type: Date, desc: "Begin date of the Billing Cycle"
          optional :end_date, type: Date, desc: "End date of the Billing Cycle"
        end
        patch ':id' do
          BillingCycleResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end

        desc "Create Regular Billings for all active Power Takers."
        params do
          requires :accounting_year, type: Integer, desc: "Accounting Year for all the Billings"
        end
        post ':id/create-regular-billings' do
          BillingCycleResource
            .retrieve(current_user, permitted_params)
            .create_regular_billings(permitted_params)
        end
      end
    end
  end
end
