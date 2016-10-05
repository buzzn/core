module API
  module V1
    class Meters < Grape::API
      include API::V1::Defaults
      resource 'meters' do


        desc "Return a Meter"
        params do
          requires :id, type: String, desc: "ID of the meter"
        end
        oauth2 :full
        get ":id" do
          Meter.guarded_retrieve(current_user, permitted_params)
        end



        desc "Create a Meter"
        params do
          requires :manufacturer_name, desc: "name of the manufacturer"
          requires :manufacturer_product_name, desc: "meter produkt name"
          requires :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          optional :smart, desc: "meter is smart"
        end
        oauth2 :full, :smartmeter
        post do
          if Meter.creatable_by?(current_user)
            meter = Meter.create!(permitted_params)
            created_response(meter)
          else
            status 403
          end
        end



        desc "Update a Meter."
        params do
          requires :id, type: String, desc: 'Meter ID.'
          optional :manufacturer_name, desc: "name of the manufacturer"
          optional :manufacturer_product_name, desc: "meter produkt name"
          optional :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          optional :smart, desc: "meter is smart"
        end
        oauth2 :full
        patch ':id' do
          meter = Meter.guarded_retrieve(current_user, permitted_params)
          if meter.updatable_by?(current_user)
            meter.update!(permitted_params)
            meter
          else
            status 403
          end
        end



        desc 'Delete a Meter.'
        params do
          requires :id, type: String, desc: 'Meter ID.'
        end
        oauth2 :full
        delete ':id' do
          meter = Meter.guarded_retrieve(current_user, permitted_params)
          if meter.deletable_by?(current_user)
            meter.destroy
            status 204
          else
            status 403
          end
        end







      end
    end
  end
end
