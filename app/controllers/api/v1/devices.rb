module API
  module V1
    class Devices < Grape::API
      include API::V1::Defaults
      resource :devices do

        desc "Return all Device"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Device.search_attributes)}"
          
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get do
          paginated_response(Device.filter(permitted_params[:filter])
                              .readable_by(current_user))
        end



        desc "Return a Device"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        oauth2 false
        get ":id" do
          Device.guarded_retrieve(current_user, permitted_params)
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
          device = Device.guarded_create(current_user, permitted_params)
          created_response(device)
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
          device = Device.guarded_retrieve(current_user, permitted_params)
          device.guarded_update(current_user, permitted_params)
        end




        desc "Delete a Device."
        params do
          requires :id, type: String, desc: "Device ID"
        end
        oauth2 :full
        delete ':id' do
          device = Device.guarded_retrieve(current_user, permitted_params)
          deleted_response(device.guarded_delete(current_user))
        end




      end
    end
  end
end
