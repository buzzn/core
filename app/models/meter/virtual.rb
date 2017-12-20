module Meter
  class Virtual < Base

    has_one :register, class_name: Register::Virtual, dependent: :destroy, foreign_key: :meter_id

    def initialize(attr = {})
      attr[:register] = Register::Virtual.new(attr[:register] || {}) if attr && attr[:register].is_a?(Hash)
      super
      register.meter = self if register
    end
  end
end
