require_relative 'base'

module Meter
  class Virtual < Base

    has_one :register, class_name: 'Register::Base', foreign_key: :meter_id

    attr_readonly :product_serialnumber

    before_create do
      self.product_serialnumber = "VM-#{Meter::Virtual.count + 1}"
    end

  end
end
