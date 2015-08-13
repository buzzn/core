module API
  module V1
    class Devices < Grape::API
      include API::V1::Defaults
      resource :devices do





        desc "Return a Device"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        get ":id", root: "device" do
          guard!
          @device = Device.where(id: permitted_params[:id]).first!
          current_user.can_read?(@device) ? @device : error_403
        end






        desc "Create a Device"
        params do
          requires :manufacturer_name,         type: String
          requires :manufacturer_product_name, type: String
          requires :mode,                      type: String, values: Device.modes
          requires :readable,                  type: String, values: Device.readables
          requires :category,                  type: String
          requires :watt_peak,                 type: Integer
          optional :commissioning,             type: DateTime
          requires :mobile,                    type: Boolean
        end
        post do
          guard!
          if current_user
            if Device.creatable_by?(current_user)
              @params = params.device || params
              @device = Device.new({
                manufacturer_name:          @params.manufacturer_name,
                manufacturer_product_name:  @params.manufacturer_product_name,
                mode:                       @params.mode,
                readable:                   @params.readable,
                category:                   @params.category,
                watt_peak:                  @params.watt_peak,
                commissioning:              @params.commissioning,
                mobile:                     @params.mobile
                })
              if @device.save!
                current_user.add_role(:manager, @device)
                return @device
              end
            else
              error_403
            end
          else
            error_401
          end
        end







        desc "Update a Device."
        params do
          requires :id,                        type: String, desc: "Device ID."
          requires :manufacturer_name,         type: String
          requires :manufacturer_product_name, type: String
          requires :mode,                      type: String, values: Device.modes
          requires :readable,                  type: String, values: Device.readables
          requires :category,                  type: String
          requires :watt_peak,                 type: Integer
          optional :commissioning,             type: DateTime
          requires :mobile,                    type: Boolean
        end
        put ':id' do
          guard!
          if current_user
            @device = Device.find(params[:id])
            if @device.updatable_by?(current_user)
              @params = params.device || params

              @device.update({
                manufacturer_name:          @params.manufacturer_name,
                manufacturer_product_name:  @params.manufacturer_product_name,
                mode:                       @params.mode,
                readable:                   @params.readable,
                category:                   @params.category,
                watt_peak:                  @params.watt_peak,
                commissioning:              @params.commissioning,
                mobile:                     @params.mobile
                })
              return @device
            else
              status 403
            end
          else
            status 401
          end
        end








      end
    end
  end
end
