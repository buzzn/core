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
          meter = Meter::Base.guarded_retrieve(current_user, permitted_params)
          Meter::GuardedBaseSerializer.new(meter, current_user: current_user)
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
            meter = Meter::Real.guarded_create(current_user, permitted_params)
            created_response(meter)
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
            meter = Meter::Real.guarded_retrieve(current_user, permitted_params)
            meter.guarded_update(current_user, permitted_params)
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
              meter = Meter::Real.unguarded_retrieve(permitted_params[:id])
              # TODO make meter.registers.guarded_create(current_user, permitted_params)
              permitted_params[:meter] = meter
              register = Register.const_get(mode.camelize).guarded_create(current_user, permitted_params)
              created_response(register)
            end
          end

          desc "Return the related Registers"
          params do
            requires :id, type: String, desc: "ID of the Meter"
          end
          oauth2 :full, :smartmeter
          get ":id/registers" do
            meter = Meter::Real.guarded_retrieve(current_user, permitted_params)
            meter.registers
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
            meter = Meter::Virtual.guarded_create(current_user, permitted_params)
            created_response(meter)
          end


          desc "Update a Virtual-Meter."
          params do
            requires :id, type: String, desc: 'Meter ID.'
            optional :manufacturer_product_name, desc: "meter produkt name"
            optional :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          end
          oauth2 :full
          patch ':id' do
            meter = Meter::Virtual.guarded_retrieve(current_user, permitted_params)
            meter.guarded_update(current_user, permitted_params)
          end


          desc "Return the related Register"
          params do
            requires :id, type: String, desc: "ID of the Meter"
          end
          oauth2 :full
          get ":id/register" do
            meter = Meter::Virtual.guarded_retrieve(current_user, permitted_params)
            meter.register
          end

        end

        desc 'Delete a Meter.'
        params do
          requires :id, type: String, desc: 'Meter ID.'
        end
        oauth2 :full
        delete ':id' do
          meter = Meter::Base.guarded_retrieve(current_user, permitted_params)
          deleted_response(meter.guarded_delete(current_user))
        end


      end
    end
  end
end
