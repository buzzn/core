module API
  module V1
    class Meters < Grape::API
      include API::V1::Defaults
      resource 'meters' do


        desc "Return a Meter"
        params do
          requires :id, type: String, desc: "ID of the meter"
        end
        get ":id" do
          doorkeeper_authorize! :manager
          meter = Meter.find(params[:id])
          if current_user
            if meter.readable_by?(current_user)
              return meter
            else
              status 403
            end
          else
            status 401
          end
        end



        desc "Create a meter"
        params do
          requires :manufacturer_name, desc: "name of the manufacturer"
          requires :manufacturer_product_name, desc: "meter produkt name"
          requires :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          optional :smart, desc: "meter is smart"
        end
        post do
          doorkeeper_authorize! :manager
          if current_user
            if Meter.creatable_by?(current_user)
              meter = Meter.new({
                manufacturer_name:                  params[:manufacturer_name],
                manufacturer_product_name:          params[:manufacturer_product_name],
                manufacturer_product_serialnumber:  params[:manufacturer_product_serialnumber],
                smart:                              params[:smart]
                })
              if meter.save!
                current_user.add_role(:manager, meter)
                return meter
              end
            else
              status 403
            end
          else
            status 401
          end
        end



        desc "Update a MeteringPoint."
        params do
          requires :id, type: String, desc: 'Meter ID.'
          requires :manufacturer_name, desc: "name of the manufacturer"
          requires :manufacturer_product_name, desc: "meter produkt name"
          requires :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          optional :smart, desc: "meter is smart"
        end
        put do
          doorkeeper_authorize! :manager
          if current_user
            meter = Meter.find(params[:id])
            if meter.updatable_by?(current_user)
              meter.update({
                manufacturer_name:                  params[:manufacturer_name],
                manufacturer_product_name:          params[:manufacturer_product_name],
                manufacturer_product_serialnumber:  params[:manufacturer_product_serialnumber],
                smart:                              params[:smart]
              })
              return meter
            else
              status 403
            end
          else
            status 401
          end
        end



        desc 'Delete a Meter.'
        params do
          requires :id, type: String, desc: 'Meter ID.'
        end
        delete ':id' do
          doorkeeper_authorize! :manager
          if current_user
            meter = Meter.find(params[:id])
            if meter.deletable_by?(current_user)
              meter.destroy
              status 204
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
