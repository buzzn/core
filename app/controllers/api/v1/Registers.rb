module API
  module V1
    class Registers < Grape::API
      include API::V1::Defaults

      # resource :registers do

      #   desc "Get Register by ID"
      #   params do
      #     requires :id, type: String, desc: "ID of the Register"
      #   end
      #   get ":id", root: "register" do
      #     Register.where(id: permitted_params[:id]).first!
      #   end

      # end

    end
  end
end
