module Meter
  class RealResource < BaseResource

    model Meter::Real

    attributes  :smart

    has_many :registers

    # API methods for the endpoints

    def create_input_register(params)
      params[:meter] = object
      Register::Input.guarded_create(@current_user, params)
    end

    def create_output_register(params)
      params[:meter] = object
      Register::Output.guarded_create(@current_user, params)
    end
  end

  # TODO get rid of the need of having a Serializer class
  class RealSerializer < RealResource
    def self.new(*args)
      super
    end
  end
end
