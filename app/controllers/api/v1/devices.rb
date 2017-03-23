module API
  module V1
    class Devices < Grape::API
      include API::V1::Defaults
      resource :devices do

        desc "Return all Device"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Device.search_attributes)}"
          optional :order_direction, type: String, default: 'DESC', values: ['DESC', 'ASC'], desc: "Ascending Order and Descending Order"
          optional :order_by, type: String, default: 'created_at', values: ['updated_at', 'created_at'], desc: "Order by Attribute"
        end
        oauth2 false
        get do
          # FIXME why do we order attributes which are not exposed to client ?
          #       ordering resources is more a job for the client
          order = "#{permitted_params[:order_by]} #{permitted_params[:order_direction]}"
          DeviceResource
            .all(current_user, permitted_params[:filter])
            .order(order)
        end



        desc "Return a Device"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        oauth2 false
        get ":id" do
          DeviceResource.retrieve(current_user, permitted_params)
        end






        desc "Create a Device"
        params do
          requires :manufacturer_name,         type: String, desc: 'manufacturer name'
          requires :manufacturer_product_name, type: String, desc: 'manufacturer product name'
          optional :mode,                      type: String, values: Device.modes, default: "in", desc: 'mode'
          optional :readable,                  type: String, values: Device.readables, default: "world", desc: 'readable permission'
          requires :category,                  type: String, desc: 'category'
          requires :watt_peak,                 type: Integer, desc: 'peak watt'
          optional :commissioning,             type: DateTime, desc: 'date when commissioning began'
          requires :mobile,                    type: Boolean, desc: 'is mobile'
        end
        oauth2 :full
        post do
          created_response(DeviceResource.create(current_user,
                                                 permitted_params))
        end







        desc "Update a Device."
        params do
          requires :id,                        type: String, desc: "Device ID."
          optional :manufacturer_name,         type: String, desc: 'manufacturer name'
          optional :manufacturer_product_name, type: String, desc: 'manufacturer product name'
          optional :mode,                      type: String, values: Device.modes, desc: 'mode'
          optional :readable,                  type: String, values: Device.readables, desc: 'readable permission'
          optional :category,                  type: String, desc: 'category'
          optional :watt_peak,                 type: Integer, desc: 'peak watt'
          optional :commissioning,             type: DateTime, desc: 'date when commissioning began'
          optional :mobile,                    type: Boolean, desc: 'is mobile'
        end
        oauth2 :full
        patch ':id' do
          DeviceResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end




        desc "Delete a Device."
        params do
          requires :id, type: String, desc: "Device ID"
        end
        oauth2 :full
        delete ':id' do
          deleted_response(DeviceResource
                            .retrieve(current_user, permitted_params)
                            .delete)
        end




      end
    end
  end
end
