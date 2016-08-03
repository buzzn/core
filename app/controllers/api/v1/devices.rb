module API
  module V1
    class Devices < Grape::API
      include API::V1::Defaults
      resource :devices do

        desc "Return all Device"
        params do
          optional :search, type: String, desc: "Search query using #{Base.join(Device.search_attributes)}"
        end
        paginate(per_page: per_page=10)
        oauth2 false
        get do
          per_page     = params[:per_page] || per_page
          page         = params[:page] || 1
          devices = Device.filter(params[:search]).readable_by(current_user)
          total_pages  = devices.page(page).per_page(per_page).total_pages
          paginate(render(devices, meta: { total_pages: total_pages }))
        end



        desc "Return a Device"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        oauth2 false
        get ":id" do
          device = Device.find(permitted_params[:id])
          if device.readable_by?(current_user)
            device
          else
            status 403
          end
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
            device = Device.new(permitted_params)
            if device.save!
              current_user.add_role(:manager, device)
            end
            device
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
        put ':id' do
          device = Device.find(permitted_params[:id])
          if device.updatable_by?(current_user)
            device.update(permitted_params)
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
          device = Device.find(permitted_params[:id])
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
