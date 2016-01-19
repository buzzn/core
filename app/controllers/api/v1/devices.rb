module API
  module V1
    class Devices < Grape::API
      include API::V1::Defaults
      resource :devices do


        desc "Return all Device"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        get ":id" do
          guard!
          @device = Device.find(params[:id])
          current_user
          if @device.readable == 'world'
            return @device
          elsif current_user
            current_user.can_read?(@device) ? @device : error_403
          end
        end



        desc "Return a Device"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        get ":id" do
          guard!
          @device = Device.find(params[:id])
          current_user
          if @device.readable == 'world'
            return @device
          elsif current_user
            current_user.can_read?(@device) ? @device : error_403
          end
        end






        desc "Create a Device"
        params do
          requires :manufacturer_name,         type: String
          requires :manufacturer_product_name, type: String
          requires :mode,                      type: String, values: Device.modes, default: "in"
          requires :readable,                  type: String, values: Device.readables, default: "world"
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
              status_403
            end
          else
            status_401
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
              status_403
            end
          else
            status_401
          end
        end




        desc "Delete a Device."
        params do
          requires :id, type: String, desc: "Device ID"
        end
        delete ':id' do
          guard!
          if current_user
            @device = Device.find(params[:id])
            if @device.deletable_by?(current_user)
              @device.destroy
              status 200
            else
              status_403
            end
          else
            status_401
          end
        end




      end
    end
  end
end
