require 'buzzn/zip2price'
module API
  module V1
    class Prices < Grape::API
      include API::V1::Defaults

      resource :prices do

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

      end
    end
  end
end
