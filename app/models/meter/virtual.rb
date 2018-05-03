require_relative 'base'

module Meter
  class Virtual < Base

    has_one :register, class_name: 'Register::Base', foreign_key: :meter_id

    def product_serialnumber=(val)
      raise ActiveRecord::ReadOnlyRecord unless new_record?
      super
    end

    before_create do
      self.product_serialnumber = "VM-#{Meter::Virtual.count + 1}"
    end

  end
end
