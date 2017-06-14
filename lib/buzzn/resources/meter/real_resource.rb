module Meter
  class RealResource < BaseResource

    model Real

    attributes  :smart

    has_many :registers

    # API methods for the endpoints

    def create_input_register(params)
      params[:meter] = object
      Register::Input.guarded_create(current_user, params)
    end

    def create_output_register(params)
      params[:meter] = object
      Register::Output.guarded_create(current_user, params)
    end
  end
end
