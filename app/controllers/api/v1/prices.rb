require 'buzzn/zip2price'
module API
  module V1
    class Prices < Grape::API
      include API::V1::Defaults

      resource :prices do

        # TODO: is this still needed or should we remove it as we have no use case for this at the moment?
        # Initially we created this for getting prices in our forms SPA
        desc 'Converts the ZIP code to estimated monthly price'
        params do
          requires :zip
          requires :yearly_kilowatt_hour
          requires :metering_type, values: Buzzn::Zip2Price.types
        end
        get do
          zip_price = Buzzn::Zip2Price.new(permitted_params[:yearly_kilowatt_hour],
                                           permitted_params[:zip],
                                           permitted_params[:metering_type])
          unless price = zip_price.to_price
            # mimic jsonapi as far as possible
            status 422
            { errors: [{
                         source: { pointer: "/data/attributes/zip" },
                         title:"Invalid Attribute",
                         detail:"unknown zip"
                       }] }
          else
            # mimic jsonapi as far as possible
            { data: { attributes: price.to_h } }
          end
        end

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
