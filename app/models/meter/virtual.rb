module Meter
  class Virtual < Base

    has_one :register, class_name: Register::Virtual, dependent: :destroy, foreign_key: :meter_id
    validates_associated :register

    validates :register, presence: true
    validates :product_name, presence: false
    validates :product_serialnumber, presence: false, uniqueness: true, allow_nil: true, length: { in: 2..128 }


    def validate_invariants
      errors.add(:manufacturer_name, 'not allowed') unless manufacturer_name.nil?
      errors.add(:direction_number, 'not allowed') unless direction_number = ONE_WAY_METER
    end

    def initialize(attr = {})
      attr[:register] = Register::Virtual.new(attr[:register] || {}) if attr && attr[:register].is_a?(Hash)
      attr[:direction_number] = ONE_WAY_METER
      super
      register.meter = self if register
    end

    # work around AR short-comings

    def valid?(*args)
      if ! super && !errors[:register].empty? && register
        register.errors.each do |key, err|
          errors.add(:"register.#{key}", err)
        end
      end
      errors.empty?
    end
  end
end
