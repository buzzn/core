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
          Meter::BaseResource.retrieve(current_user, permitted_params)
        end



        namespace :real do

          desc "Create a Real-Meter with a Input-Register and/or Output-Register"
          params do
            requires :manufacturer_name, desc: "name of the manufacturer"
            requires :manufacturer_product_name, desc: "meter produkt name"
            requires :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
            optional :input_register, type: Hash do
              requires :name, type: String, desc: "name"
              requires :readable, type: String, desc: "readable by?", values: Register::Base.readables
              optional :uid, type: String, desc: "UID(DE00...)"
            end
            optional :output_register, type: Hash do
              requires :name, type: String, desc: "name"
              requires :readable, type: String, desc: "readable by?", values: Register::Base.readables
              optional :uid, type: String, desc: "UID(DE00...)"
            end
          end
          oauth2 :full, :smartmeter
          post do
            created_response(Meter::RealResource.create(current_user, permitted_params))
          end


          desc "Update a Real-Meter."
          params do
            requires :id, type: String, desc: 'Meter ID.'
            optional :manufacturer_name, desc: "name of the manufacturer"
            optional :manufacturer_product_name, desc: "meter produkt name"
            optional :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          end
          oauth2 :full
          patch ':id' do
            Meter::RealResource
              .retrieve(current_user, permitted_params)
              .update(permitted_params)
          end


          ["input", "output"].each do |mode|
            desc "Create a #{mode} Register for the Meter"
            params do
              requires :id, type: String, desc: "ID of the Meter"
              requires :name, type: String, desc: "name"
              requires :readable, type: String, desc: "readable by", values: Register::Base.readables
              optional :uid, type: String, desc: "UID(DE00...)"
            end
            oauth2 :full, :smartmeter
            post ":id/#{mode}_register" do
              created_response(Meter::RealResource
                                .retrieve(current_user, permitted_params)
                                .send("create_#{mode}_register".to_sym,
                                      permitted_params))
            end
          end

          desc "Return the related Registers"
          params do
            requires :id, type: String, desc: "ID of the Meter"
          end
          oauth2 :full, :smartmeter
          get ":id/registers" do
            Meter::RealResource
              .retrieve(current_user, permitted_params)
              .registers
          end

        end


        namespace :virtual do

          desc "Create a Virtual-Meter with a Virtual-Register"
          params do
            optional :manufacturer_product_name, desc: "meter produkt name"
            optional :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
            requires :register, type: Hash do
              requires :name, type: String, desc: "name"
              requires :direction, type: String, desc: "direction of the meter.", values: Register::Base.directions
              requires :readable, type: String, desc: "readable by?", values: Register::Base.readables
            end
          end
          oauth2 :full
          post do
            created_response(Meter::VirtualResource
                              .create(current_user, permitted_params))
          end


          desc "Update a Virtual-Meter."
          params do
            requires :id, type: String, desc: 'Meter ID.'
            optional :manufacturer_product_name, desc: "meter produkt name"
            optional :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          end
          oauth2 :full
          patch ':id' do
            Meter::VirtualResource
              .retrieve(current_user, permitted_params)
              .update(permitted_params)
          end


          desc "Return the related Register"
          params do
            requires :id, type: String, desc: "ID of the Meter"
          end
          oauth2 :full
          get ":id/register" do
            Meter::VirtualResource
              .retrieve(current_user, permitted_params)
              .register
          end

        end

        desc 'Delete a Meter.'
        params do
          requires :id, type: String, desc: 'Meter ID.'
        end
        oauth2 :full
        delete ':id' do
          deleted_response(Meter::BaseResource
                            .retrieve(current_user, permitted_params)
                            .delete)
        end


      end
    end
  end
end
