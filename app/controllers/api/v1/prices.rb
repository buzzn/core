module API
  module V1
    class Prices < Grape::API
      include API::V1::Defaults

      resource :prices do

        desc "Update a Price."
        params do
          requires :id, type: String, desc: "Price ID"
          optional :name, type: String, desc: "Name of the price"
          optional :begin_date, type: String, desc: "The price's begin date"
          optional :energyprice_cents_per_kilowatt_hour, type: Float, desc: "The price per kilowatt_hour in cents"
          optional :baseprice_cents_per_month, type: Integer, desc: "The monthly base price in cents"
        end
        patch ':id' do
          PriceResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end
      end
    end
  end
end
