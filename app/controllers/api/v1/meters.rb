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
          Meter::BaseResource.retrieve(current_user, permitted_params)
        end

        namespace :real do

          desc "Return the related Registers"
          params do
            requires :id, type: String, desc: "ID of the Meter"
          end
          get ":id/registers" do
            Meter::RealResource
              .retrieve(current_user, permitted_params)
              .registers
          end

        end

        namespace :virtual do

          desc "Return the related Register"
          params do
            requires :id, type: String, desc: "ID of the Meter"
          end
          get ":id/register" do
            Meter::VirtualResource
              .retrieve(current_user, permitted_params)
              .register
          end
        end
      end
    end
  end
end
