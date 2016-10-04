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
          requires :manufacturer_name,         type: String
          requires :manufacturer_product_name, type: String
          optional :mode,                      type: String, values: Device.modes, default: "in"
          optional :readable,                  type: String, values: Device.readables, default: "world"
          requires :category,                  type: String
          requires :watt_peak,                 type: Integer
          optional :commissioning,             type: DateTime
          requires :mobile,                    type: Boolean
        end
        oauth2 :full
        post do
          if Device.creatable_by?(current_user)
            # TODO cleanup move logic into Device and ensure manager (via validation)
            device = Device.create!(permitted_params)
            current_user.add_role(:manager, device)
            created_response(device)
          else
            status_403
          end
        end







        desc "Update a Device."
        params do
          requires :id,                        type: String, desc: "Device ID."
          optional :manufacturer_name,         type: String
          optional :manufacturer_product_name, type: String
          optional :mode,                      type: String, values: Device.modes
          optional :readable,                  type: String, values: Device.readables
          optional :category,                  type: String
          optional :watt_peak,                 type: Integer
          optional :commissioning,             type: DateTime
          optional :mobile,                    type: Boolean
        end
        oauth2 :full
        patch ':id' do
          device = Device.guarded_retrieve(current_user, permitted_params)
          if device.updatable_by?(current_user)
            device.update!(permitted_params)
            device
          else
            status 403
          end
        end




        desc "Delete a Device."
        params do
          requires :id, type: String, desc: "Device ID"
        end
        oauth2 :full
        delete ':id' do
          device = Device.guarded_retrieve(current_user, permitted_params)
          if device.deletable_by?(current_user)
            device.destroy
            status 204
          else
            status 403
          end
        end




      end
    end
  end
end
