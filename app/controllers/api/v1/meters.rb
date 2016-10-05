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
          meter = Meter.guarded_create(current_user, permitted_params)
          created_response(meter)
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
          meter.guarded_update(current_user, permitted_params)
        end



        desc 'Delete a Meter.'
        params do
          requires :id, type: String, desc: 'Meter ID.'
        end
        oauth2 :full
        delete ':id' do
          meter = Meter.guarded_retrieve(current_user, permitted_params)
          deleted_response(meter.guarded_delete(current_user))
        end







      end
    end
  end
end
